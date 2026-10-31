import { ChmEncoding } from './ChmEncoding';
import { ChmFile } from './ChmFile';
import { ChmPath } from './ChmPath';
import { ChmSystem } from './ChmSystem';
import { TocItem } from './TocItem';

/**
 * CHM 目录读取（移植自 Android ChmToc / CoolReader chmfmt.cpp 的 CHMTOCReader）。
 * 优先解析 .hhc（text/sitemap 结构），失败时按文件名生成伪目录。
 */
export class ChmToc {
  items: TocItem[];
  pages: string[];
  defaultPage: string;

  private constructor(items: TocItem[], pages: string[], defaultPage: string) {
    this.items = items;
    this.pages = pages;
    this.defaultPage = defaultPage;
  }

  static build(file: ChmFile, system: ChmSystem): ChmToc {
    let items: TocItem[] = [];
    const hhc = system.getContentsFile();
    if (hhc !== '' && file.hasFile(hhc)) {
      const data = file.read(hhc);
      if (data !== null && data.length > 0) {
        items = ChmToc.parseHhc(data, hhc, system.getCharset());
      }
    }
    if (items.length === 0) {
      items = ChmToc.buildFakeToc(file);
    }
    const pages = ChmToc.buildPageList(file, items);
    const defaultPage = ChmToc.pickDefaultPage(file, system, items, pages);
    return new ChmToc(items, pages, defaultPage);
  }

  private static pickDefaultPage(file: ChmFile, system: ChmSystem, items: TocItem[], pages: string[]): string {
    const topic = system.getDefaultTopic();
    if (topic !== '' && file.hasFile(ChmPath.stripQueryAndFragment(topic))) {
      return topic;
    }
    for (const item of items) {
      if (item.hasUrl() && file.hasFile(ChmPath.stripQueryAndFragment(item.url))) {
        return item.url;
      }
    }
    return pages.length > 0 ? pages[0] : '';
  }

  private static buildPageList(file: ChmFile, items: TocItem[]): string[] {
    const pages: string[] = [];
    const seen: Set<string> = new Set<string>();
    for (const item of items) {
      if (!item.hasUrl()) {
        continue;
      }
      const path = ChmPath.normalize(ChmPath.stripQueryAndFragment(item.url));
      if (file.hasFile(path) && !seen.has(path)) {
        seen.add(path);
        pages.push(path);
      }
    }

    const remaining: string[] = [];
    for (const name of file.getFiles()) {
      const path = ChmPath.normalize(name);
      if (!ChmPath.isHtml(path) || seen.has(path) || ChmToc.isSkippedPage(path)) {
        continue;
      }
      remaining.push(path);
    }
    remaining.sort((left: string, right: string): number => ChmToc.compareFileNames(left, right));
    for (const path of remaining) {
      if (!seen.has(path)) {
        seen.add(path);
        pages.push(path);
      }
    }
    return pages;
  }

  private static isSkippedPage(path: string): boolean {
    const lower = path.toLowerCase();
    return lower === '/bookindex.htm' || lower === '/headerindex.htm';
  }

  private static buildFakeToc(file: ChmFile): TocItem[] {
    const html: string[] = [];
    for (const name of file.getFiles()) {
      const path = ChmPath.normalize(name);
      if (ChmPath.isHtml(path) && !ChmToc.isSkippedPage(path)) {
        html.push(path);
      }
    }
    html.sort((left: string, right: string): number => ChmToc.compareFileNames(left, right));
    const result: TocItem[] = [];
    for (const path of html) {
      result.push(new TocItem(ChmToc.pageTitle(path), path, 0));
    }
    return result;
  }

  private static pageTitle(path: string): string {
    let name = path.startsWith('/') ? path.substring(1) : path;
    const lower = name.toLowerCase();
    if (lower.endsWith('.html')) {
      name = name.substring(0, name.length - 5);
    } else if (lower.endsWith('.htm')) {
      name = name.substring(0, name.length - 4);
    }
    return name;
  }

  private static parseHhc(data: Uint8Array, hhcPath: string, fallbackCharset: string): TocItem[] {
    const charset = ChmEncoding.detect(data, fallbackCharset, false);
    const html = ChmEncoding.decode(data, charset);

    const result: TocItem[] = [];
    const tagRe = /<\s*(\/?)\s*(ul|object)\b/gi;
    const objectEndRe = /<\s*\/\s*object\s*>/gi;
    let depth = 0;
    let minLevel = 0x7FFFFFFF;

    let match: RegExpExecArray | null = tagRe.exec(html);
    while (match !== null) {
      const closing = match[1] !== undefined && match[1] !== '';
      const tag = match[2].toLowerCase();
      if (tag === 'ul') {
        depth += closing ? -1 : 1;
        if (depth < 0) {
          depth = 0;
        }
        match = tagRe.exec(html);
        continue;
      }
      if (closing) {
        match = tagRe.exec(html);
        continue;
      }
      // <object> 开始：截取到 </object>
      const blockStart = match.index + match[0].length;
      objectEndRe.lastIndex = blockStart;
      const endMatch = objectEndRe.exec(html);
      const blockEnd = endMatch === null ? html.length : endMatch.index;
      const block = html.substring(blockStart, blockEnd);
      const params = ChmToc.parseParams(block);
      const name = params.get('name');
      const localRaw = params.get('local');
      if (name !== undefined && localRaw !== undefined) {
        const local = localRaw.trim();
        if (local !== '') {
          const url = ChmPath.resolve(hhcPath, local);
          if (url !== '') {
            const level = Math.max(0, depth - 1);
            if (level < minLevel) {
              minLevel = level;
            }
            result.push(new TocItem(ChmToc.cleanTitle(name), ChmToc.urlWithFragment(url, local), level));
          }
        }
      }
      match = tagRe.exec(html);
    }

    if (minLevel === 0x7FFFFFFF || minLevel === 0) {
      return result;
    }
    const normalized: TocItem[] = [];
    for (const item of result) {
      normalized.push(new TocItem(item.title, item.url, Math.max(0, item.level - minLevel)));
    }
    return normalized;
  }

  private static urlWithFragment(absolutePath: string, rawLocal: string): string {
    const fragment = ChmPath.fragmentOf(rawLocal);
    return fragment === '' ? absolutePath : absolutePath + '#' + fragment;
  }

  /** 解析 <param name="..." value="...">（键名大小写不敏感）。 */
  private static parseParams(block: string): Map<string, string> {
    const params: Map<string, string> = new Map<string, string>();
    const tagRe = /<param\b[^>]*>/gi;
    const attrRe = /(name|value)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))/gi;
    let tagMatch: RegExpExecArray | null = tagRe.exec(block);
    while (tagMatch !== null) {
      const tag = tagMatch[0];
      let name = '';
      let value = '';
      let hasName = false;
      let hasValue = false;
      let attrMatch: RegExpExecArray | null = attrRe.exec(tag);
      while (attrMatch !== null) {
        const key = attrMatch[1].toLowerCase();
        let attrValue = '';
        if (attrMatch[2] !== undefined) {
          attrValue = attrMatch[2];
        } else if (attrMatch[3] !== undefined) {
          attrValue = attrMatch[3];
        } else if (attrMatch[4] !== undefined) {
          attrValue = attrMatch[4];
        }
        if (key === 'name') {
          name = attrValue;
          hasName = true;
        } else {
          value = attrValue;
          hasValue = true;
        }
        attrMatch = attrRe.exec(tag);
      }
      if (hasName && hasValue) {
        params.set(name.toLowerCase(), value);
      }
      tagMatch = tagRe.exec(block);
    }
    return params;
  }

  /** 去掉 HTML 标签与实体（对应 Android 的 Html.fromHtml）。 */
  private static cleanTitle(value: string): string {
    const text = ChmToc.decodeEntities(value.replace(/<[^>]*>/g, ''))
      .replace(/\u00A0/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
    return text === '' ? value.trim() : text;
  }

  private static decodeEntities(text: string): string {
    const named = text
      .replace(/&nbsp;/gi, ' ')
      .replace(/&lt;/gi, '<')
      .replace(/&gt;/gi, '>')
      .replace(/&quot;/gi, '"')
      .replace(/&apos;/gi, '\'')
      .replace(/&amp;/gi, '&');
    const re = /&#(x[0-9a-fA-F]+|[0-9]+);/g;
    let out = '';
    let last = 0;
    let match: RegExpExecArray | null = re.exec(named);
    while (match !== null) {
      out += named.substring(last, match.index);
      const body = match[1];
      const isHex = body.charAt(0) === 'x' || body.charAt(0) === 'X';
      const code = isHex ? parseInt(body.substring(1), 16) : parseInt(body, 10);
      out += String.fromCharCode(code);
      last = match.index + match[0].length;
      match = re.exec(named);
    }
    out += named.substring(last);
    return out;
  }

  /** 移植 CoolReader chmfmt.cpp 的 filename_comparator。 */
  static compareFileNames(left: string, right: string): number {
    let s1 = left.startsWith('/') ? left.substring(1) : left;
    let s2 = right.startsWith('/') ? right.substring(1) : right;
    s1 = ChmToc.stripExtension(s1);
    s2 = ChmToc.stripExtension(s2);
    if (s1 === 'index') {
      return -1;
    }
    if (s2 === 'index') {
      return 1;
    }
    if (s1 === 'header') {
      return -1;
    }
    if (s2 === 'header') {
      return 1;
    }
    const n1 = ChmToc.leadingNumber(s1);
    const n2 = ChmToc.leadingNumber(s2);
    if (n1 !== 0 || n2 !== 0) {
      if (n1 !== 0 && n2 !== 0) {
        return n1 - n2;
      }
      return n1 !== 0 ? -1 : 1;
    }
    if (s1 === s2) {
      return 0;
    }
    return s1 < s2 ? -1 : 1;
  }

  private static stripExtension(value: string): string {
    const lower = value.toLowerCase();
    if (lower.endsWith('.htm')) {
      return value.substring(0, value.length - 4);
    }
    if (lower.endsWith('.html')) {
      return value.substring(0, value.length - 5);
    }
    return value;
  }

  private static leadingNumber(value: string): number {
    let result = 0;
    let i = 0;
    while (i < value.length) {
      const code = value.charCodeAt(i);
      if (code < 0x30 || code > 0x39) {
        break;
      }
      result = result * 10 + (code - 0x30);
      i++;
      if (result > 100000000) {
        break;
      }
    }
    return result;
  }
}
