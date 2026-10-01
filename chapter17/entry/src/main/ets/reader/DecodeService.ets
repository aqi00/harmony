/**
 * 解码服务（主线程外观，对应 Android DecodeServiceBase 的公开 API）。
 * 内部通过单一 Worker 串行化所有 native 调用，结果以 Promise 返回。
 */
import worker, { MessageEvents, ErrorEvent } from '@ohos.worker';
import {
  WorkerResponse,
  DecodedPageResult,
  OpenRequest,
  DecodePageRequest,
  RecycleRequest
} from './DjvuTypes';

export class DecodeService {
  private worker: worker.ThreadWorker;
  // 每页解码回调按 pageNum 路由（可并发多个 in-flight）。
  private decodeWaiters: Map<number, (w: number, h: number, buf: ArrayBuffer) => void> =
    new Map<number, (w: number, h: number, buf: ArrayBuffer) => void>();
  private decodeRejects: Map<number, (e: Error) => void> =
    new Map<number, (e: Error) => void>();
  private openResolver: ((count: number) => void) | null = null;
  private openRejecter: ((e: Error) => void) | null = null;
  private recycleResolver: (() => void) | null = null;
  private disposed = false;

  constructor() {
    console.info('DecodeService constructor begin ')
    this.worker = new worker.ThreadWorker('../reader/DjvuWorker.ets');
    console.info('DecodeService constructor 1 ')
    this.worker.onmessage = (e: MessageEvents) => {
      this.onWorkerMessage(e.data as WorkerResponse);
    };
    console.info('DecodeService constructor 2 ')
    this.worker.onerror = (e: ErrorEvent) => {
      this.failAll(new Error(e.message ?? 'worker error'));
    };
    console.info('DecodeService constructor end')
  }

  private onWorkerMessage(resp: WorkerResponse): void {
    switch (resp.type) {
      case 'opened':
        if (this.openResolver) {
          this.openResolver(resp.pageCount);
          this.openResolver = null;
          this.openRejecter = null;
        }
        break;
      case 'pageDecoded': {
        const resolve = this.decodeWaiters.get(resp.pageNum);
        if (resolve) {
          resolve(resp.width, resp.height, resp.buffer);
          this.decodeWaiters.delete(resp.pageNum);
          this.decodeRejects.delete(resp.pageNum);
        }
        break;
      }
      case 'error': {
        const err = new Error(resp.message);
        // 优先拒绝在途的 open，其次逐个解码
        if (this.openRejecter) {
          this.openRejecter(err);
          this.openResolver = null;
          this.openRejecter = null;
        }
        this.failDecodes(err);
        break;
      }
      case 'recycled':
        if (this.recycleResolver) {
          this.recycleResolver();
          this.recycleResolver = null;
        }
        break;
    }
  }

  /** 打开文档并等待 DOCINFO，返回总页数（在 worker 线程执行，不冻 UI）。 */
  open(path: string): Promise<number> {
    return new Promise<number>((resolve, reject) => {
      this.openResolver = resolve;
      this.openRejecter = reject;
      const req: OpenRequest = { type: 'open', path };
      this.worker.postMessage(req);
    });
  }

  /** 解码单页，返回 RGBA_8888 缓冲与宽高。 */
  decodePage(pageNum: number, containerWidth: number): Promise<DecodedPageResult> {
    return new Promise<DecodedPageResult>((resolve, reject) => {
      this.decodeWaiters.set(pageNum, (w, h, buf) => {
        const result: DecodedPageResult = { width: w, height: h, buffer: buf };
        resolve(result);
      });
      this.decodeRejects.set(pageNum, reject);
      const req: DecodePageRequest = { type: 'decodePage', pageNum, containerWidth };
      this.worker.postMessage(req);
    });
  }

  /** 释放所有资源（对应 Android DecodeServiceBase.recycle）。 */
  recycle(): Promise<void> {
    return new Promise<void>((resolve) => {
      this.recycleResolver = resolve;
      const req: RecycleRequest = { type: 'recycle' };
      this.worker.postMessage(req);
    });
  }

  private failDecodes(err: Error): void {
    this.decodeRejects.forEach((r) => r(err));
    this.decodeWaiters.clear();
    this.decodeRejects.clear();
  }

  private failAll(err: Error): void {
    if (this.openRejecter) {
      this.openRejecter(err);
      this.openResolver = null;
      this.openRejecter = null;
    }
    this.failDecodes(err);
  }

  /** 销毁 worker（页面销毁时调用）。 */
  terminate(): void {
    if (this.disposed) {
      return;
    }
    this.disposed = true;
    this.worker.terminate();
  }
}
