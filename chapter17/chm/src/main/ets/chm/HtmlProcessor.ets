import { util } from '@kit.ArkTS';

import { ChmEncoding } from './ChmEncoding';
import { ChmPath } from './ChmPath';

const UTF8_META = '<meta charset="utf-8">';
const VIEWPORT = '<meta name="viewport" content="width=device-width, initial-scale=1">';
const READER_STYLE = '<style id="cr-chm-reader-style">'
  + 'html{-webkit-text-size-adjust:100%;}'
  + 'body{word-wrap:break-word;overflow-wrap:break-word;}'
  + 'img{max-width:100%!important;height:auto!important;}'
  + 'table{max-width:100%!important;}'
  + 'pre{white-space:pre-wrap;word-wrap:break-word;}'
  + '</style>';

/**
 * 将 CHM 内的 HTML / CSS 转为 UTF-8 后交给 Web 组件
 * （移植自 Android HtmlProcessor，对应 CoolReader 统一切换编码的做法）。
 */
export class HtmlProcessor {
  /** HTML → UTF-8 字节（注入 charset / viewport / 阅读样式）。 */
  static prepareHtml(raw: Uint8Array, fallback: string): Uint8Array {
    const charset = ChmEncoding.detect(raw, fallback, false);
    let content = ChmEncoding.decode(raw, charset);
    content = content.replace(/<meta[^>]*charset\s*=[^>]*>/gi, '');
    content = content.replace(/<meta[^>]*http-equiv\s*=\s*["']?content-type[^>]*>/gi, '');

    let inject = UTF8_META;
    if (!/<meta[^>]+name\s*=\s*["']?viewport/i.test(content)) {
      inject += VIEWPORT;
    }
    inject += READER_STYLE;

    const head = /<head\b[^>]*>/i.exec(content);
    if (head !== null) {
      const pos = head.index + head[0].length;
      content = content.substring(0, pos) + inject + content.substring(pos);
    } else {
      const htmlTag = /<html\b[^>]*>/i.exec(content);
      if (htmlTag !== null) {
        const pos = htmlTag.index + htmlTag[0].length;
        content = content.substring(0, pos) + '<head>' + inject + '</head>' + content.substring(pos);
      } else {
        content = inject + content;
      }
    }
    return new util.TextEncoder().encodeInto(content);
  }

  /** CSS → UTF-8 字节（统一 @charset）。 */
  static prepareCss(raw: Uint8Array, fallback: string): Uint8Array {
    const charset = ChmEncoding.detect(raw, fallback, true);
    let content = ChmEncoding.decode(raw, charset);
    content = content.replace(/@charset\s+[^;]+;/gi, '');
    return new util.TextEncoder().encodeInto('@charset "utf-8";\n' + content);
  }

  /** 扩展名 → MIME 类型（对应 Android HtmlProcessor.mimeType）。 */
  static mimeType(path: string): string {
    const ext = ChmPath.fileExtension(path);
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'ico':
        return 'image/x-icon';
      case 'js':
        return 'application/javascript';
      case 'json':
        return 'application/json';
      case 'xml':
      case 'hhc':
      case 'hhk':
        return 'text/xml';
      case 'txt':
        return 'text/plain';
      case 'woff':
        return 'font/woff';
      case 'woff2':
        return 'font/woff2';
      case 'ttf':
        return 'font/ttf';
      case 'otf':
        return 'font/otf';
      case 'eot':
        return 'application/vnd.ms-fontobject';
      case 'swf':
        return 'application/x-shockwave-flash';
      default:
        return 'application/octet-stream';
    }
  }
}
