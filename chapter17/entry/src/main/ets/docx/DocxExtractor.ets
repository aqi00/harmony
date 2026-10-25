import { TxtUtils } from "./TxtUtils";
import { ZipUtils } from "./ZipUtils";


/**
 * ArkTS 版 DocxExtractor —— 从 styles.xml 提取文档语言代码。
 *
 * 鸿蒙 XmlPullParser 没有 Android 的流式遍历 API，这里直接用正则匹配 styles.xml。
 */
export class DocxExtractor {

  /**
   * 获取 docx 文档的语言代码（如 "zh-CN"、"en-US"）。
   * 从 styles.xml 中查找 w:lang 属性。
   *
   * @param docxPath docx 文件在沙箱内的绝对路径
   * @returns 语言代码，未找到时返回空字符串
   */
  static async getLang(docxPath: string): Promise<string> {
    try {
      const xmlText: string = await ZipUtils.getEntryText(docxPath, 'word/styles.xml');
      if (TxtUtils.isEmpty(xmlText)) {
        console.info('DocxExtractor styles.xml not found in zip');
        return '';
      }

      // 分别匹配 w:val 和 w:eastAsia 属性（之前用单一正则 + 可选捕获组，
      // 非贪婪 [^>]*? 会把属性吞掉导致捕获组不触发，m[1]/m[2] 全为 null）。
      // 改为两次独立匹配，简单可靠。
      const valMatch = xmlText.match(/<w:lang\b[^>]*?\bw:val="([^"]+)"/);
      const eaMatch = xmlText.match(/<w:lang\b[^>]*?\bw:eastAsia="([^"]+)"/);
      const val = (valMatch && valMatch[1]) ? valMatch[1] : '';
      const eaVal = (eaMatch && eaMatch[1]) ? eaMatch[1] : '';
      const result = TxtUtils.isEmpty(val) ? eaVal : val;
      console.info('DocxExtractor lang val=', val, ' eastAsia=', eaVal, ' -> ', result);
      return TxtUtils.isEmpty(result) ? '' : result;

    } catch (e) {
      console.info('DocxExtractor.getLang failed', String(e));
    }
    return '';
  }
}
