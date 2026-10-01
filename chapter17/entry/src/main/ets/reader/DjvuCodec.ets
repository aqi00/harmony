/**
 * DJVU 解码器 NAPI 包装（对应 Android DjvuContext/DjvuDocument/DjvuPage）。
 * 在 Worker 线程内使用，对 native libdjvu.so 的薄封装。
 */
import djvu from 'libdjvu.so';
import { CodecContext, CodecDocument, CodecPage, RectF } from './DjvuTypes';

/** 上下文（对应 DjvuContext.java）：持有 native 上下文句柄。 */
export class DjvuContext implements CodecContext {
  private ctxHandle: bigint = 0n;

  constructor() {
    this.ctxHandle = djvu.djvuCreate();
  }

  openDocument(fileName: string): DjvuDocument {
    const docHandle: bigint = djvu.djvuOpen(this.ctxHandle, fileName);
    return new DjvuDocument(docHandle);
  }

  recycle(): void {
    if (this.ctxHandle !== 0n) {
      djvu.djvuContextFree(this.ctxHandle);
      this.ctxHandle = 0n;
    }
  }
}

/** 文档（对应 DjvuDocument.java）。 */
export class DjvuDocument implements CodecDocument {
  private docHandle: bigint = 0n;

  constructor(handle: bigint) {
    this.docHandle = handle;
  }

  getPage(pageNo: number): DjvuPage {
    return new DjvuPage(djvu.djvuGetPage(this.docHandle, pageNo));
  }

  getPageCount(): number {
    return djvu.djvuGetPageCount(this.docHandle);
  }

  recycle(): void {
    if (this.docHandle !== 0n) {
      djvu.djvuDocumentFree(this.docHandle);
      this.docHandle = 0n;
    }
  }
}

/** 页（对应 DjvuPage.java）：渲染结果为 RGBA_8888 Uint8Array。 */
export class DjvuPage implements CodecPage {
  private pageHandle: bigint = 0n;

  constructor(handle: bigint) {
    this.pageHandle = handle;
  }

  getWidth(): number {
    return djvu.djvuPageGetWidth(this.pageHandle);
  }

  getHeight(): number {
    return djvu.djvuPageGetHeight(this.pageHandle);
  }

  /**
   * 渲染整页（slice=0,0,1,1）到 width*height*4 的 RGBA_8888 缓冲。
   * 调用方负责用 image.createPixelMap 转为 PixelMap。
   */
  renderBitmap(width: number, height: number, slice: RectF): Uint8Array {
    const buf = new Uint8Array(width * height * 4);
    djvu.djvuRenderPage(this.pageHandle, width, height,
      slice.left, slice.top, slice.width, slice.height, buf);
    return buf;
  }

  recycle(): void {
    if (this.pageHandle !== 0n) {
      djvu.djvuPageFree(this.pageHandle);
      this.pageHandle = 0n;
    }
  }
}
