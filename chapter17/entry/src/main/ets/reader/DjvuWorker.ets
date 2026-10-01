/**
 * DJVU 解码 Worker（运行在独立线程，串行化所有 native 调用以维持
 * 「同 context 不并发」不变量，对应 Android DecodeServiceBase 的单线程执行器）。
 *
 * 拥有：DjvuContext + DjvuDocument + 页句柄 LRU 缓存（PAGE_POOL_SIZE=16）。
 */
import worker, { MessageEvents } from '@ohos.worker';
import { DjvuContext, DjvuDocument, DjvuPage } from './DjvuCodec';
import { WorkerRequest, WorkerResponse } from './DjvuTypes';
import { RenderConst } from './RenderConst';

const workerPort = worker.workerPort;

let ctx: DjvuContext | null = null;
let doc: DjvuDocument | null = null;
const pages: Map<number, DjvuPage> = new Map<number, DjvuPage>();
const evictionQueue: number[] = [];

workerPort.onmessage = (e: MessageEvents) => {
  const req = e.data as WorkerRequest;
  try {
    switch (req.type) {
      case 'open':
        handleOpen(req.path);
        break;
      case 'decodePage':
        handleDecode(req.pageNum, req.containerWidth);
        break;
      case 'recycle':
        cleanup();
        post({ type: 'recycled' });
        break;
    }
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    post({ type: 'error', message: msg });
  }
};

function handleOpen(path: string): void {
  ctx = new DjvuContext();
  doc = ctx.openDocument(path);
  const pageCount = doc.getPageCount();
  post({ type: 'opened', pageCount });
}

function handleDecode(pageNum: number, containerWidth: number): void {
  if (!doc) {
    post({ type: 'error', message: 'document not opened' });
    return;
  }
  const page = getPage(pageNum);
  // 对齐 Android DecodeServiceBase.calculateScale：scale = targetWidth / pageWidth
  const scale = containerWidth / page.getWidth();
  const w = Math.round(scale * page.getWidth());
  const h = Math.round(scale * page.getHeight());
  const buf = page.renderBitmap(w, h, { left: 0, top: 0, width: 1, height: 1 });
  const resp: WorkerResponse = {
    type: 'pageDecoded', pageNum: pageNum, width: w, height: h, buffer: buf.buffer as ArrayBuffer
  };
  // 转移 ArrayBuffer 所有权到主线程（worker 侧 buf 即刻失效）。
  workerPort.postMessage(resp, [buf.buffer]);
}

/** 页句柄 LRU 缓存（对应 Android DecodeServiceBase.getPage LRU）。 */
function getPage(pageNum: number): DjvuPage {
  const cached = pages.get(pageNum);
  if (cached) {
    return cached;
  }
  const p = doc!.getPage(pageNum);
  pages.set(pageNum, p);
  evictionQueue.push(pageNum);
  while (evictionQueue.length > RenderConst.PAGE_POOL_SIZE) {
    const evicted = evictionQueue.shift();
    if (evicted === undefined) {
      break;
    }
    const ep = pages.get(evicted);
    if (ep) {
      ep.recycle();
      pages.delete(evicted);
    }
  }
  return p;
}

function cleanup(): void {
  for (const p of pages.values()) {
    p.recycle();
  }
  pages.clear();
  evictionQueue.length = 0;
  if (doc) {
    doc.recycle();
    doc = null;
  }
  if (ctx) {
    ctx.recycle();
    ctx = null;
  }
}

function post(resp: WorkerResponse): void {
  workerPort.postMessage(resp);
}

// function errToString(err: Object): string {
//   if (err && typeof err === 'object' && 'message' in err) {
//     return String((err as Record<string, Object>).message);
//   }
//   return String(err);
// }
