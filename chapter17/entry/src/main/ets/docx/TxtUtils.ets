/**
 * ArkTS 版 TxtUtils —— 替代 Android com.foobnix.android.utils.TxtUtils。
 */
export class TxtUtils {
  static NON_BREAKE_SPACE: string = '\u00A0';

  static isEmpty(txt: string | undefined | null): boolean {
    return txt === undefined || txt === null || txt.trim().length === 0;
  }

  static isNotEmpty(txt: string | undefined | null): boolean {
    return !TxtUtils.isEmpty(txt);
  }

  static nullToEmpty(txt: Object | undefined | null): string {
    if (txt === undefined || txt === null) return '';
    return String(txt).trim();
  }

  static join(delim: string, items: Object[]): string {
    if (items === undefined || items.length === 0) return '';
    let sb: string = '';
    for (let i = 0; i < items.length; i++) {
      if (i > 0) sb += delim;
      sb += (items[i] === null ? '@null' : String(items[i]));
    }
    return sb;
  }

  static trim(s: string | undefined | null): string {
    if (s === undefined || s === null) return '';
    return s.replace(/\s+/g, ' ').trim();
  }
}
