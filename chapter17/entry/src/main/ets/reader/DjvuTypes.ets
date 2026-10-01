/**
 * DJVU 解码相关接口与类型（合并自 Android org/vudroid/core/codec/*.java）。
 */
import image from '@ohos.multimedia.image';

/** 矩形切片，对应 Android RectF（left/top/width/height 归一化）。 */
export interface RectF {
  left: number;
  top: number;
  width: number;
  height: number;
}

/** 上下文接口（对应 CodecContext.java）。 */
export interface CodecContext {
  openDocument(fileName: string): CodecDocument;
  recycle(): void;
}

/** 文档接口（对应 CodecDocument.java）。 */
export interface CodecDocument {
  getPage(pageNo: number): CodecPage;
  getPageCount(): number;
  recycle(): void;
}

/** 页接口（对应 CodecPage.java）。 */
export interface CodecPage {
  getWidth(): number;
  getHeight(): number;
  renderBitmap(width: number, height: number, slice: RectF): Uint8Array;
  recycle(): void;
}

/** 解码回调，对应 Android DecodeService.DecodeCallback（参数由 Bitmap 改为 PixelMap）。 */
export interface DecodeCallback {
  decodeComplete(pixelMap: image.PixelMap): void;
}

/** 单页解码结果（DecodeService.decodePage 的返回值，避免内联对象字面量类型）。 */
export interface DecodedPageResult {
  width: number;
  height: number;
  buffer: ArrayBuffer;
}

/** Worker 通信消息：主线程 → Worker。 */
export interface OpenRequest {
  type: 'open';
  path: string;
}

export interface DecodePageRequest {
  type: 'decodePage';
  pageNum: number;
  containerWidth: number;
}

export interface RecycleRequest {
  type: 'recycle';
}

export type WorkerRequest = OpenRequest | DecodePageRequest | RecycleRequest;

/** Worker 通信消息：Worker → 主线程。 */
export interface OpenedResponse {
  type: 'opened';
  pageCount: number;
}

export interface PageDecodedResponse {
  type: 'pageDecoded';
  pageNum: number;
  width: number;
  height: number;
  buffer: ArrayBuffer;
}

export interface ErrorResponse {
  type: 'error';
  message: string;
}

export interface RecycledResponse {
  type: 'recycled';
}

export type WorkerResponse = OpenedResponse | PageDecodedResponse | ErrorResponse | RecycledResponse;
