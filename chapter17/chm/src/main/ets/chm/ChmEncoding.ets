import { util } from '@kit.ArkTS';

/**
 * 编码探测与解码（移植自 Android ChmEncoding）。
 * 使用 util.TextDecoder 解码，编码名统一用 WHATWG 标签（如 gbk / big5 / windows-1252）。
 */
export class ChmEncoding {
  static readonly DEFAULT_ENCODING: string = 'windows-1252';

  /** LCID → Windows 代码页（主语言 ID 覆盖常见语言）。 */
  static codepageForLcid(lcid: number): number {
    const primary = lcid & 0x3FF;
    switch (primary) {
      case 0x01:
        return 1256; // Arabic
      case 0x02:
        return 1251; // Bulgarian
      case 0x04:
        // 0x0404 台湾 / 0x0C04 香港 / 0x1404 澳门 → Big5，其余 → GBK
        if (lcid === 0x0404 || lcid === 0x0C04 || lcid === 0x1404) {
          return 950;
        }
        return 936; // Chinese
      case 0x05:
        return 1250; // Czech
      case 0x08:
        return 1253; // Greek
      case 0x0D:
        return 1255; // Hebrew
      case 0x0E:
        return 1250; // Hungarian
      case 0x11:
        return 932; // Japanese
      case 0x12:
        return 949; // Korean
      case 0x15:
        return 1250; // Polish
      case 0x18:
        return 1250; // Romanian
      case 0x19:
        return 1251; // Russian
      case 0x1A:
        return 1250; // Croatian / Serbian
      case 0x1B:
        return 1250; // Slovak
      case 0x1C:
        return 1250; // Albanian
      case 0x1E:
        return 874; // Thai
      case 0x1F:
        return 1254; // Turkish
      case 0x20:
        return 1256; // Urdu
      case 0x22:
        return 1251; // Ukrainian
      case 0x23:
        return 1251; // Belarusian
      case 0x24:
        return 1250; // Slovenian
      case 0x25: // Estonian
      case 0x26: // Latvian
      case 0x27:
        return 1257; // Lithuanian
      case 0x29:
        return 1256; // Farsi
      case 0x2A:
        return 1258; // Vietnamese
      case 0x2B:
        return 1252; // Armenian
      case 0x2F:
        return 1251; // Macedonian
      default:
        return 1252;
    }
  }

  /** 代码页 → 编码标签。 */
  static encodingForCodepage(codepage: number): string {
    switch (codepage) {
      case 936:
        return 'gbk';
      case 950:
        return 'big5';
      case 932:
        return 'shift_jis';
      case 949:
        return 'euc-kr';
      case 874:
        return 'windows-874';
      case 1200:
        return 'utf-16le';
      case 1201:
        return 'utf-16be';
      case 65001:
        return 'utf-8';
      case 20127:
        return 'us-ascii';
      case 20866:
        return 'koi8-r';
      case 21866:
        return 'koi8-u';
      case 10000:
        return 'macintosh';
      default:
        if (codepage >= 1250 && codepage <= 1258) {
          return 'windows-' + codepage;
        }
        return ChmEncoding.DEFAULT_ENCODING;
    }
  }

  /** 编码别名归一（对应 Android charsetForCodepageName）。 */
  static encodingForName(name: string): string | null {
    if (name === null || name === undefined) {
      return null;
    }
    const lower = name.trim().toLowerCase();
    if (lower === '') {
      return null;
    }
    let normalized = '';
    if (lower === 'gb2312' || lower === 'gbk' || lower === 'gb_2312-80') {
      normalized = 'gbk';
    } else if (lower === 'gb18030') {
      normalized = 'gb18030';
    } else if (lower === 'utf8' || lower === 'utf-8') {
      normalized = 'utf-8';
    } else if (lower === 'big5' || lower === 'big-5') {
      normalized = 'big5';
    } else if (lower === 'sjis' || lower === 'shift-jis' || lower === 'shift_jis' || lower === 'x-sjis') {
      normalized = 'shift_jis';
    } else if (lower === 'euc-kr' || lower === 'ks_c_5601-1987') {
      normalized = 'euc-kr';
    } else if (lower === 'iso-8859-1' || lower === 'latin1' || lower === 'windows-1252') {
      normalized = 'windows-1252';
    } else if (lower === 'utf-16' || lower === 'utf-16le') {
      normalized = 'utf-16le';
    } else if (lower === 'utf-16be') {
      normalized = 'utf-16be';
    } else if (lower === 'ascii' || lower === 'us-ascii') {
      normalized = 'us-ascii';
    } else {
      normalized = lower;
    }
    return ChmEncoding.isSupported(normalized) ? normalized : null;
  }

  /** 是否是 util.TextDecoder 可识别的编码标签。 */
  static isSupported(encoding: string): boolean {
    const known = ['gbk', 'gb18030', 'big5', 'shift_jis', 'euc-kr', 'utf-8', 'utf-16le', 'utf-16be',
      'us-ascii', 'koi8-r', 'koi8-u', 'macintosh', 'windows-874'];
    if (known.indexOf(encoding) >= 0) {
      return true;
    }
    if (encoding.startsWith('windows-125') || encoding.startsWith('iso-8859-')) {
      return true;
    }
    return false;
  }

  /** 字体名末尾的字符集编号（如 "宋体,134"）→ 编码（对应 Android charsetFromFont）。 */
  static charsetFromFont(font: string): string | null {
    if (font === null || font === undefined) {
      return null;
    }
    const comma = font.lastIndexOf(',');
    if (comma < 0 || comma + 1 >= font.length) {
      return null;
    }
    const tail = font.substring(comma + 1).trim();
    let value = 0;
    let i = 0;
    while (i < tail.length && tail.charCodeAt(i) >= 0x30 && tail.charCodeAt(i) <= 0x39) {
      value = value * 10 + (tail.charCodeAt(i) - 0x30);
      i++;
    }
    if (i === 0) {
      return null;
    }
    switch (value) {
      case 0xCC:
        return ChmEncoding.encodingForCodepage(1251);
      case 0xEE:
        return ChmEncoding.encodingForCodepage(1250);
      case 0xA1:
        return ChmEncoding.encodingForCodepage(1253);
      case 0xA2:
        return ChmEncoding.encodingForCodepage(1254);
      case 0xBA:
        return ChmEncoding.encodingForCodepage(1257);
      case 0xB1:
        return ChmEncoding.encodingForCodepage(1255);
      case 0xB2:
        return ChmEncoding.encodingForCodepage(1256);
      case 0x00:
        return ChmEncoding.encodingForCodepage(1252);
      default:
        return null;
    }
  }

  /** 从 HTML/CSS 头部探测编码，失败时返回 fallback。 */
  static detect(data: Uint8Array, fallback: string, css: boolean): string {
    if (data === null || data === undefined || data.length === 0) {
      return fallback === null || fallback === undefined ? ChmEncoding.DEFAULT_ENCODING : fallback;
    }
    const sampleLength = Math.min(data.length, 4096);
    const sample = ChmEncoding.latin1(data.subarray(0, sampleLength));

    const metaRe = /charset\s*=\s*["']?\s*([a-zA-Z0-9_\-:.]+)/i;
    const cssRe = /@charset\s+["']([^"']+)["']/i;
    const primary = css ? cssRe : metaRe;
    const matched = sample.match(primary);
    if (matched !== null && matched.length > 1) {
      const found = ChmEncoding.encodingForName(matched[1]);
      if (found !== null) {
        return found;
      }
    }
    if (!css) {
      const cssMatched = sample.match(cssRe);
      if (cssMatched !== null && cssMatched.length > 1) {
        const found = ChmEncoding.encodingForName(cssMatched[1]);
        if (found !== null) {
          return found;
        }
      }
    }
    return fallback === null || fallback === undefined ? ChmEncoding.DEFAULT_ENCODING : fallback;
  }

  /** 解码字节串，自动处理 BOM。 */
  static decode(data: Uint8Array, encoding: string): string {
    if (data === null || data === undefined || data.length === 0) {
      return '';
    }
    let offset = 0;
    let enc = encoding;
    if (data.length >= 3 && data[0] === 0xEF && data[1] === 0xBB && data[2] === 0xBF) {
      offset = 3;
      enc = 'utf-8';
    } else if (data.length >= 2 && data[0] === 0xFF && data[1] === 0xFE) {
      offset = 2;
      enc = 'utf-16le';
    } else if (data.length >= 2 && data[0] === 0xFE && data[1] === 0xFF) {
      offset = 2;
      enc = 'utf-16be';
    }
    if (enc === null || enc === undefined || enc === '') {
      enc = ChmEncoding.DEFAULT_ENCODING;
    }
    const view = offset === 0 ? data : data.subarray(offset);
    try {
      const options: util.TextDecoderOptions = { ignoreBOM: true };
      const decoder = util.TextDecoder.create(enc, options);
      return decoder.decodeToString(view);
    } catch (e) {
      return ChmEncoding.latin1(view);
    }
  }

  /** ISO-8859-1 解码（逐字节映射，作为兜底解码）。 */
  static latin1(data: Uint8Array): string {
    if (data === null || data === undefined || data.length === 0) {
      return '';
    }
    let out = '';
    for (let i = 0; i < data.length; i++) {
      out += String.fromCharCode(data[i]);
    }
    return out;
  }
}
