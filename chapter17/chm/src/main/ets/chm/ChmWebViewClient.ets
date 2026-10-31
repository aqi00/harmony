import { ChmFile } from './ChmFile';
import { ChmPath } from './ChmPath';
import { ChmSystem } from './ChmSystem';
import { HtmlProcessor } from './HtmlProcessor';

/** 资源加载决策（对应 Android shouldOverrideUrlLoading 的返回值）。 */
export class LoadDecision {
  /** true 表示拦截（不由 Web 直接加载）。 */
  intercept: boolean;
  /** 非空表示需要改为加载该 URL（如 mk:@MSITStore 转换后的地址）。 */
  redirect: string;

  constructor(intercept: boolean, redirect: string) {
    this.intercept = intercept;
    this.redirect = redirect;
  }
}

/**
 * 通过 onInterceptRequest 把 https://chm.local/... 映射到 CHM 内部文件，
 * 这样页面里的相对链接、图片、CSS 都能正常工作（移植自 Android ChmWebViewClient）。
 */
export class ChmWebViewClient {
  static readonly HOST: string = 'chm.local';
  static readonly BASE_URL: string = 'https://chm.local';

  private chmFile: ChmFile;
  private system: ChmSystem;

  /** 打开外部链接（应用无法处理时）。 */
  onOpenExternal: ((url: string) => void) | null = null;
  /** 主框架页面不存在。 */
  onMissingPage: ((path: string) => void) | null = null;
  /** 页面加载完成（参数为 CHM 内部路径）。 */
  onPageLoaded: ((path: string) => void) | null = null;

  constructor(file: ChmFile, system: ChmSystem) {
    this.chmFile = file;
    this.system = system;
  }

  /** 对应 shouldInterceptRequest：为虚拟域返回 CHM 内容。 */
  handleRequest(requestUrl: string, mainFrame: boolean): WebResourceResponse {
    const response = new WebResourceResponse();
    response.setResponseCode(200);
    response.setResponseEncoding('utf-8');

    const path = ChmPath.normalize(ChmWebViewClient.pathOf(requestUrl));
    const raw = this.chmFile.read(path);
    if (raw === null) {
      if (mainFrame && this.onMissingPage !== null) {
        this.onMissingPage(path);
      }
      response.setResponseCode(404);
      response.setResponseMimeType('text/plain');
      response.setResponseData(new ArrayBuffer(0));
      return response;
    }

    if (ChmPath.isHtml(path)) {
      const body = HtmlProcessor.prepareHtml(raw, this.system.getCharset());
      response.setResponseMimeType('text/html');
      response.setResponseData(ChmWebViewClient.toArrayBuffer(body));
      return response;
    }
    if (ChmPath.isCss(path)) {
      const body = HtmlProcessor.prepareCss(raw, this.system.getCharset());
      response.setResponseMimeType('text/css');
      response.setResponseData(ChmWebViewClient.toArrayBuffer(body));
      return response;
    }
    response.setResponseMimeType(HtmlProcessor.mimeType(path));
    response.setResponseData(ChmWebViewClient.toArrayBuffer(raw));
    return response;
  }

  /** 对应 shouldOverrideUrlLoading：决定是否拦截或重定向。 */
  handleLoad(url: string): LoadDecision {
    if (url === '') {
      return new LoadDecision(true, '');
    }
    if (ChmWebViewClient.isInternalUrl(url)) {
      return new LoadDecision(false, '');
    }
    const lower = url.toLowerCase();
    if (lower.startsWith('about:') || lower.startsWith('data:') || lower.startsWith('javascript:')) {
      return new LoadDecision(false, '');
    }
    const msIts = ChmWebViewClient.convertMsIts(url);
    if (msIts !== '') {
      return new LoadDecision(true, msIts);
    }
    if (this.onOpenExternal !== null) {
      this.onOpenExternal(url);
    }
    return new LoadDecision(true, '');
  }

  /** 对应 onPageFinished：把 URL 还原为 CHM 内部路径。 */
  handlePageFinished(url: string): void {
    if (this.onPageLoaded === null) {
      return;
    }
    if (ChmWebViewClient.hostOf(url) === ChmWebViewClient.HOST) {
      const path = ChmWebViewClient.pathOf(url);
      if (path !== '' && path !== '/') {
        this.onPageLoaded(ChmPath.normalize(path));
      }
    }
  }

  /** 是否属于 CHM 虚拟域。 */
  static isInternalUrl(url: string): boolean {
    const lower = url.toLowerCase();
    if (lower === ChmWebViewClient.BASE_URL) {
      return true;
    }
    return lower.startsWith(ChmWebViewClient.BASE_URL + '/')
      || lower.startsWith(ChmWebViewClient.BASE_URL + '#');
  }

  /** 处理 mk:@MSITStore:...::/page.htm 与 ms-its:file.chm::/page.htm。 */
  static convertMsIts(url: string): string {
    const lower = url.toLowerCase();
    if (!lower.startsWith('ms-its:') && !lower.startsWith('mk:@msitstore:')) {
      return '';
    }
    const separator = url.indexOf('::');
    if (separator < 0) {
      return '';
    }
    let path = url.substring(separator + 2);
    let fragment = '';
    const hash = path.indexOf('#');
    if (hash >= 0) {
      fragment = path.substring(hash);
      path = path.substring(0, hash);
    }
    if (path === '') {
      return '';
    }
    return ChmWebViewClient.BASE_URL + ChmPath.encodeUrlPath(ChmPath.normalize(path)) + fragment;
  }

  /** CHM 内部路径（可带锚点）→ Web 可加载的 URL。 */
  static buildUrl(chmPathWithAnchor: string): string {
    const fragment = ChmPath.fragmentOf(chmPathWithAnchor);
    const path = ChmPath.normalize(ChmPath.stripQueryAndFragment(chmPathWithAnchor));
    const encoded = ChmPath.encodeUrlPath(path);
    return fragment === '' ? ChmWebViewClient.BASE_URL + encoded
      : ChmWebViewClient.BASE_URL + encoded + '#' + fragment;
  }

  /** 取 URL 的主机名。 */
  static hostOf(url: string): string {
    const lower = url.toLowerCase();
    const schemeEnd = lower.indexOf('://');
    if (schemeEnd < 0) {
      return '';
    }
    let rest = lower.substring(schemeEnd + 3);
    const slash = rest.indexOf('/');
    if (slash >= 0) {
      rest = rest.substring(0, slash);
    }
    const query = rest.indexOf('?');
    if (query >= 0) {
      rest = rest.substring(0, query);
    }
    const hash = rest.indexOf('#');
    if (hash >= 0) {
      rest = rest.substring(0, hash);
    }
    const port = rest.lastIndexOf(':');
    if (port > 0) {
      rest = rest.substring(0, port);
    }
    return rest;
  }

  /** 取 URL 的路径部分（已解码，去查询串与锚点）。 */
  static pathOf(url: string): string {
    const schemeEnd = url.indexOf('://');
    if (schemeEnd < 0) {
      return '/';
    }
    const start = url.indexOf('/', schemeEnd + 3);
    if (start < 0) {
      return '/';
    }
    const path = ChmPath.decodeUrlPath(ChmPath.stripQueryAndFragment(url.substring(start)));
    return path === '' ? '/' : path;
  }

  private static toArrayBuffer(data: Uint8Array): ArrayBuffer {
    return data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength) as ArrayBuffer;
  }
}
