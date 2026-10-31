import { util } from '@kit.ArkTS';

/**
 * CHM 内部路径工具（移植自 Android ChmPath）。
 * CHM 中的文件名以 "/" 开头，使用 "/" 分隔。
 */
export class ChmPath {
  /** 统一路径分隔符，并保证以 "/" 开头。 */
  static normalize(path: string): string {
    if (path === null || path === undefined) {
      return '';
    }
    let result = path.trim().replace(/\\/g, '/');
    if (result === '') {
      return '';
    }
    if (result.charAt(0) !== '/') {
      result = '/' + result;
    }
    return result;
  }

  /** 去掉 URL 查询串与锚点。 */
  static stripQueryAndFragment(url: string): string {
    if (url === null || url === undefined) {
      return '';
    }
    let cut = url.length;
    const hash = url.indexOf('#');
    if (hash >= 0 && hash < cut) {
      cut = hash;
    }
    const query = url.indexOf('?');
    if (query >= 0 && query < cut) {
      cut = query;
    }
    return url.substring(0, cut);
  }

  static fragmentOf(url: string): string {
    if (url === null || url === undefined) {
      return '';
    }
    const hash = url.indexOf('#');
    return hash >= 0 ? url.substring(hash + 1) : '';
  }

  static dirName(path: string): string {
    if (path === null || path === undefined) {
      return '/';
    }
    const p = path.replace(/\\/g, '/');
    const slash = p.lastIndexOf('/');
    if (slash <= 0) {
      return '/';
    }
    return p.substring(0, slash);
  }

  /** 以 base 为基准解析 href（base 可以是页面路径或 .hhc 路径）。 */
  static resolve(base: string, href: string): string {
    if (href === null || href === undefined) {
      return '';
    }
    const clean = ChmPath.stripQueryAndFragment(href).replace(/\\/g, '/').trim();
    if (clean === '') {
      return '';
    }
    if (clean.charAt(0) === '/') {
      return ChmPath.collapse(clean);
    }
    const baseDir = ChmPath.dirName(base);
    return ChmPath.collapse(baseDir + '/' + clean);
  }

  private static collapse(path: string): string {
    const stack: string[] = [];
    const parts = path.split('/');
    for (const part of parts) {
      if (part === '' || part === '.') {
        continue;
      }
      if (part === '..') {
        if (stack.length > 0) {
          stack.pop();
        }
        continue;
      }
      stack.push(part);
    }
    if (stack.length === 0) {
      return '/';
    }
    let builder = '';
    for (const part of stack) {
      builder += '/' + part;
    }
    return builder;
  }

  static isHtml(path: string): boolean {
    const lower = path === null || path === undefined ? '' : path.toLowerCase();
    return lower.endsWith('.htm') || lower.endsWith('.html') || lower.endsWith('.xhtml');
  }

  static isCss(path: string): boolean {
    return path !== null && path !== undefined && path.toLowerCase().endsWith('.css');
  }

  static fileExtension(path: string): string {
    if (path === null || path === undefined) {
      return '';
    }
    const dot = path.lastIndexOf('.');
    if (dot < 0 || dot < path.lastIndexOf('/')) {
      return '';
    }
    return path.substring(dot + 1).toLowerCase();
  }

  /** 生成可被 Web 组件接受的 URL 路径（保留 "/" 与 "#"）。 */
  static encodeUrlPath(path: string): string {
    if (path === null || path === undefined) {
      return '';
    }
    const bytes = new util.TextEncoder().encodeInto(path);
    let builder = '';
    for (let i = 0; i < bytes.length; i++) {
      const b = bytes[i];
      const isPlain = (b >= 0x61 && b <= 0x7A) || (b >= 0x41 && b <= 0x5A)
        || (b >= 0x30 && b <= 0x39)
        || b === 0x2D || b === 0x5F || b === 0x2E || b === 0x7E
        || b === 0x2F || b === 0x23 || b === 0x3A;
      if (isPlain) {
        builder += String.fromCharCode(b);
      } else {
        const hex = b.toString(16).toUpperCase();
        builder += '%' + (hex.length === 1 ? '0' + hex : hex);
      }
    }
    return builder;
  }

  /** 反向解码 URL 路径（对应 Android Uri#getPath 的解码行为）。 */
  static decodeUrlPath(path: string): string {
    try {
      return decodeURIComponent(path);
    } catch (e) {
      return path;
    }
  }
}
