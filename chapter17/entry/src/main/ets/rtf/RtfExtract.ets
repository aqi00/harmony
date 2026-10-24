/**
 * RTF → HTML 抽取入口（对应 Android 侧 com.foobnix.ext.RtfExtract）。
 *
 * 流程：RTF 文件 → RtfParser（词法/编码/图片）→ HTML（图片另存到同目录）→ ArkWeb 渲染。
 */
import { util } from '@kit.ArkTS';

import { FileUtil } from './FileUtil';
import { IRtfImageWriter, RtfParser } from './RtfParser';

const TAG = 'RtfExtract';

/** 抽取结果：HTML 文件绝对路径 + HTML 文本内容。 */
export interface RtfExtractResult {
  htmlPath: string;
  html: string;
}

/**
 * 图片写出器。
 *  - 按 Android 侧命名规则（htmlName + 序号 + ".rtf." + 真实扩展名）把图片落盘，便于校验提取结果；
 *  - 同时返回 base64 data URI 供 <img src> 使用，使 ArkWeb 用 loadData 渲染时
 *    不依赖 file:// 相对路径解析，避免图片无法显示。
 */
class RtfImageWriter implements IRtfImageWriter {
  private outputDir: string;
  private fileName: string;
  private counter: number = 0;

  constructor(outputDir: string, fileName: string) {
    this.outputDir = outputDir;
    this.fileName = fileName;
  }

  writeImage(data: Uint8Array, declaredFormat: string): string {
    const ext = detectImageType(data, declaredFormat);
    const name = this.fileName + this.counter + '.rtf.' + ext;
    this.counter++;

    try {
      FileUtil.writeBytes(this.outputDir + '/' + name, data);
    } catch (e) {
      console.error(`${TAG} write image file fail: ${e}`);
    }

    const base64 = new util.Base64Helper().encodeToStringSync(data);
    return 'data:' + mimeOf(ext) + ';base64,' + base64;
  }
}

/** RTF 声明的图片格式可能与实际内容不符，按文件头魔数判断真实格式（对齐 Android detectImageType）。 */
function detectImageType(data: Uint8Array, fallback: string): string {
  if (data.length >= 4) {
    if (data[0] === 0x47 && data[1] === 0x49 && data[2] === 0x46 && data[3] === 0x38) {
      return 'gif';
    }
    if (data[0] === 0x89 && data[1] === 0x50 && data[2] === 0x4E && data[3] === 0x47) {
      return 'png';
    }
    if (data[0] === 0xFF && data[1] === 0xD8 && data[2] === 0xFF) {
      return 'jpg';
    }
    if (data[0] === 0x42 && data[1] === 0x4D) {
      return 'bmp';
    }
  }
  return fallback;
}

function mimeOf(ext: string): string {
  if (ext === 'gif') {
    return 'image/gif';
  }
  if (ext === 'png') {
    return 'image/png';
  }
  if (ext === 'jpg' || ext === 'jpeg') {
    return 'image/jpeg';
  }
  if (ext === 'bmp') {
    return 'image/bmp';
  }
  return 'image/png';
}

export class RtfExtract {
  /** 解析 inputPath 指向的 RTF 文件，返回 HTML 路径与内容。 */
  static extract(inputPath: string, outputDir: string, htmlName: string): RtfExtractResult {
    let content = FileUtil.readBytes(inputPath)
    return RtfExtract.extractBytes(content, outputDir, htmlName);
  }

  /** 解析内存中的 RTF 字节（用于「打开文件」选中的文档）。 */
  static extractBytes(bytes: Uint8Array, outputDir: string, htmlName: string): RtfExtractResult {
    FileUtil.ensureDir(outputDir);

    const writer = new RtfImageWriter(outputDir, htmlName);
    const body = new RtfParser(writer).parse(bytes);

    // 原 Android 实现未声明 charset/viewport，由 WebView 设置控制；
    // ArkWeb 用 loadData 渲染，这里显式声明以保证中文编码与手机端排版正确。
    const html = '<!DOCTYPE html>\n<html>\n<head>\n'
      + '<meta charset="utf-8">\n'
      + '<meta name="viewport" content="width=device-width, initial-scale=1.0">\n'
      + '</head>\n<body>\n'
      + body
      + '\n</body>\n</html>\n';

    const htmlPath = outputDir + '/' + htmlName;
    FileUtil.writeText(htmlPath, html);

    return { htmlPath: htmlPath, html: html };
  }
}
