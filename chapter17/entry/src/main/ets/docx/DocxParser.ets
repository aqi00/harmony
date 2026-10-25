import { ZipUtils } from './ZipUtils';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';

/** 解析结果接口。 */
export interface ParseResult {
  html: string;
  images: string[];
  error?: string;
  success: boolean;
}

interface RunStyles {
  bold: boolean;
  italic: boolean;
  underline: boolean;
  color: string;       // 十六进制颜色值，不带 #，如 "FF0000"；空串表示无
  fontFamily: string;  // 字体名，优先取 eastAsia，如 "黑体"；空串表示无
  fontSizePt: number;  // 字号（pt），从 w:sz 半点值除以 2 得到；0 表示无
}

/**
 * ArkTS 版 DocxParser —— docx → HTML（带图片）。
 *
 * 鸿蒙 XmlPullParser 是回调式 API，没有 Android 那种 next()/getAttributeValue() 流式遍历，
 * 因此本类用正则 + 字符串处理解析 document.xml，覆盖常见元素：
 * 段落、标题、加粗、斜体、下划线、图片。
 */
export class DocxParser {

  /** 将 docx 文件转换为 HTML（带图片）。 */
  static async convertToHtml(docxPath: string, imagesDir: string): Promise<ParseResult> {
    // 用时间戳做唯一目录名，避免 rmdirSync 删非空目录失败
    console.info('DocxParser.convertToHtml docxPath: ', docxPath);
    console.info('DocxParser.convertToHtml imagesDir: ', imagesDir);
    const tempDir = imagesDir + '_unzipped_' + Date.now();
    let result: ParseResult;
    try {
      console.info('DocxParser.convertToHtml tempDir: ', tempDir);
      ZipUtils.mkdirs(tempDir);
      ZipUtils.mkdirs(tempDir+'/word');
      const entries = await ZipUtils.unzipToDir(docxPath, tempDir);
      if (entries.length === 0) {
        result = { html: '', images: [], success: false, error: '解压失败或空 zip' };
      } else {
        const docXmlPath = tempDir + '/word/document.xml';
        console.info('DocxParser.convertToHtml docXmlPath: ', docXmlPath);
        const html = DocxParser.parseDocumentXml(docXmlPath, tempDir, imagesDir);
        if (!html) {
          result = { html: '', images: [], success: false, error: 'document.xml 解析结果为空' };
        } else {
          console.info('DocxParser HTML length =', html.length);
          result = { html, images: [], success: true };
        }
      }
    } catch (e) {
      console.info('DocxParser.convertToHtml failed', String(e));
      result = { html: '', images: [], success: false, error: String(e) };
    } finally {
      DocxParser.deleteDirRecursive(tempDir);
    }
    return result;
  }

  /** 递归删除目录（rmdirSync 只删空目录）。 */
  private static deleteDirRecursive(dir: string): void {
    try {
      if (!fileIo.accessSync(dir)) return;
      const items: string[] = fileIo.listFileSync(dir);
      for (const item of items) {
        const full = dir + '/' + item;
        try {
          const stat = fileIo.statSync(full);
          if (stat.isDirectory()) {
            DocxParser.deleteDirRecursive(full);
          } else {
            fileIo.unlinkSync(full);
          }
        } catch (_e) { /* ignore */ }
      }
      fileIo.rmdirSync(dir);
    } catch (_e) { /* ignore */ }
  }

  /** 读文件为 UTF-8 字符串。 */
  private static readText(path: string): string {
    const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
    try {
      const size: number = fileIo.statSync(file.fd).size;
      const buf = new ArrayBuffer(size);
      fileIo.readSync(file.fd, buf);
      const decoder = util.TextDecoder.create('utf-8');
      try { return decoder.decodeToString(new Uint8Array(buf)); }
      catch (e) { return decoder.decode(new Uint8Array(buf)); }
    } finally {
      fileIo.closeSync(file);
    }
  }

  /** 解析 word/document.xml，返回 HTML。 */
  private static parseDocumentXml(
    docXmlPath: string,
    unzipDir: string,
    imagesDir: string
  ): string {
    let xmlText = DocxParser.readText(docXmlPath);

    // 移除 XML 声明和 xmlns 声明（简化正则）
    xmlText = xmlText.replace(/<\?xml[^?]*\?>/g, '');

    // 1) 按 <w:p>...</w:p> 拆段落
    const paragraphRegex = /<w:p\b[^>]*>([\s\S]*?)<\/w:p>/g;
    let html = '';
    let m: RegExpExecArray | null;

    while ((m = paragraphRegex.exec(xmlText)) !== null) {
      const paraContent = m[1];
      const paraHtml = DocxParser.parseParagraph(paraContent, unzipDir, imagesDir);
      html += paraHtml;
    }

    return html;
  }

  /** 解析单个 <w:p> 内部。 */
  private static parseParagraph(
    paraContent: string,
    unzipDir: string,
    imagesDir: string
  ): string {
    // 1) 提取段落样式（Heading1~6）
    let paragraphStyle = '';
    const styleMatch = paraContent.match(/<w:pStyle\b[^>]*w:val="([^"]+)"[^>]*\/>/);
    if (styleMatch) paragraphStyle = styleMatch[1];

    // 2) 提取段落对齐 <w:jc w:val="center|left|right|both"/>
    let paragraphAlign = '';
    const jcMatch = paraContent.match(/<w:jc\b[^>]*?\bw:val="([^"]+)"/);
    if (jcMatch) paragraphAlign = jcMatch[1].toLowerCase();

    // 3) 提取所有 <w:r>...</w:r>
    const runRegex = /<w:r\b[^>]*>([\s\S]*?)<\/w:r>/g;
    let paraHtml = '';
    let m: RegExpExecArray | null;

    while ((m = runRegex.exec(paraContent)) !== null) {
      const runContent = m[1];
      paraHtml += DocxParser.parseRun(runContent, unzipDir, imagesDir);
    }

    return DocxParser.wrapParagraph(paraHtml, paragraphStyle, paragraphAlign);
  }

  /** 解析单个 <w:r> 内部（run 样式 + 文本 + 图片）。 */
  private static parseRun(
    runContent: string,
    unzipDir: string,
    imagesDir: string
  ): string {
    // 提取 run 样式 <w:rPr>...</w:rPr>
    const bold = /<w:b\b/.test(runContent) || /<w:b\s*\/>/.test(runContent);
    const italic = /<w:i\b/.test(runContent) || /<w:i\s*\/>/.test(runContent);
    const underline = /<w:u\b/.test(runContent) || /<w:u\s*\/>/.test(runContent);

    // 颜色 <w:color w:val="FF0000"/>，忽略 val="auto"
    let color = '';
    const colorM = runContent.match(/<w:color\b[^>]*?\bw:val="([0-9A-Fa-f]{6})"/);
    if (colorM) color = colorM[1].toUpperCase();

    // 字体 <w:rFonts w:ascii="黑体" w:eastAsia="黑体"/>，优先 eastAsia
    let fontFamily = '';
    const fontsM = runContent.match(/<w:rFonts\b[^>]*?\bw:eastAsia="([^"]+)"/);
    if (fontsM) {
      fontFamily = fontsM[1];
    } else {
      const asciiM = runContent.match(/<w:rFonts\b[^>]*?\bw:ascii="([^"]+)"/);
      if (asciiM) fontFamily = asciiM[1];
    }

    // 字号 <w:sz w:val="32"/>，单位是半点（half-point），除以 2 得到 pt
    let fontSizePt = 0;
    const szM = runContent.match(/<w:sz\b[^>]*?\bw:val="(\d+)"/);
    if (szM) {
      const halfPt = parseInt(szM[1], 10);
      if (halfPt > 0) fontSizePt = halfPt / 2;
    }

    const styles: RunStyles = { bold, italic, underline, color, fontFamily, fontSizePt };

    let textHtml = '';

    // 硬换行 <w:br/> 或 <w:br w:type="..."/>
    const brCount = (runContent.match(/<w:br\b[^>]*\/>/g) ?? []).length;
    for (let i = 0; i < brCount; i++) textHtml += '<br/>';

    // 提取所有 <w:t>...</w:t>
    const tRegex = /<w:t\b[^>]*>([\s\S]*?)<\/w:t>/g;
    let m: RegExpExecArray | null;
    while ((m = tRegex.exec(runContent)) !== null) {
      textHtml += DocxParser.escapeHtml(m[1]);
    }

    // 处理图片 <w:drawing>...<a:blip r:embed="rIdX"/>...
    const embedRegex = /r:embed="([^"]+)"/g;
    let embedM: RegExpExecArray | null;
    while ((embedM = embedRegex.exec(runContent)) !== null) {
      const imgHtml = DocxParser.resolveImage(unzipDir, imagesDir, embedM[1]);
      textHtml += imgHtml;
    }

    return DocxParser.wrapRun(textHtml, styles);
  }

  /** 从 document.xml.rels 查 rId → media/xxx.ext，拷贝图片并生成 <img>。 */
  private static resolveImage(unzipDir: string, imagesDir: string, embedId: string): string {
    try {
      const relsPath = unzipDir + '/word/_rels/document.xml.rels';
      const relsXml = DocxParser.readText(relsPath);
      const regex = new RegExp('Id="' + embedId + '"[^>]*Target="([^"]+)"', 'i');
      const m = relsXml.match(regex);
      if (!m) {
        console.info('resolveImage rels not found for', embedId);
        return '';
      }
      let target: string = m[1];
      if (target.startsWith('../')) target = target.substring(3);
      const mediaSource = unzipDir + '/word/' + target;

      const fileName = target.substring(target.lastIndexOf('/') + 1);
      const destPath = imagesDir + '/' + fileName;
      ZipUtils.mkdirs(imagesDir);
      try {
        fileIo.copyFileSync(mediaSource, destPath);
      } catch (e) {
        console.info('resolveImage copy failed', String(e));
        return '';
      }

      const fileUri = 'file://' + destPath;
      return '<img src="' + fileUri + '" style="max-width:100%;height:auto;margin:8px 0"/>';
    } catch (e) {
      console.info('resolveImage failed', embedId, String(e));
      return '';
    }
  }

  // ---------- 工具 ----------

  private static wrapRun(text: string, styles: RunStyles): string {
    if (!text) return '';
    let result = text;

    // 颜色/字体/字号 用 <span style="..."> 包内层
    const spanStyles: string[] = [];
    if (styles.color) spanStyles.push('color:#' + styles.color);
    if (styles.fontFamily) spanStyles.push("font-family:'" + styles.fontFamily + "'");
    if (styles.fontSizePt > 0) spanStyles.push('font-size:' + styles.fontSizePt + 'pt');
    if (spanStyles.length > 0) {
      result = '<span style="' + spanStyles.join(';') + '">' + result + '</span>';
    }

    // 下划线/斜体/加粗 用标签包外层
    if (styles.underline) result = '<u>' + result + '</u>';
    if (styles.italic) result = '<i>' + result + '</i>';
    if (styles.bold) result = '<b>' + result + '</b>';
    return result;
  }

  private static wrapParagraph(content: string, styleName: string, align: string): string {
    if (!content.trim()) return '';

    // 对齐：both → justify；left 是默认不输出；center/right/justify 显式输出
    let alignStyle = '';
    if (align === 'center') alignStyle = 'text-align:center';
    else if (align === 'right') alignStyle = 'text-align:right';
    else if (align === 'both') alignStyle = 'text-align:justify';
    // left 或不识别 → 不输出（HTML 默认左对齐）

    const styleAttr = alignStyle ? ' style="' + alignStyle + '"' : '';

    const s = (styleName || '').toLowerCase();
    if (s.includes('heading1') || s.includes('标题1')) return '<h1' + styleAttr + '>' + content + '</h1>\n';
    if (s.includes('heading2') || s.includes('标题2')) return '<h2' + styleAttr + '>' + content + '</h2>\n';
    if (s.includes('heading3') || s.includes('标题3')) return '<h3' + styleAttr + '>' + content + '</h3>\n';
    if (s.includes('heading4')) return '<h4' + styleAttr + '>' + content + '</h4>\n';
    if (s.includes('heading5')) return '<h5' + styleAttr + '>' + content + '</h5>\n';
    if (s.includes('heading6')) return '<h6' + styleAttr + '>' + content + '</h6>\n';
    return '<p' + styleAttr + '>' + content + '</p>\n';
  }

  private static escapeHtml(s: string): string {
    return s
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
