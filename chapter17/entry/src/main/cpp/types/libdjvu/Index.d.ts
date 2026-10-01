/**
 * libdjvu.so NAPI 模块类型声明
 * 对应 native: entry/src/main/cpp/napi_init.cpp
 */

export const djvuCreate: () => bigint;
export const djvuContextFree: (ctx: bigint) => void;
export const djvuOpen: (ctx: bigint, path: string) => bigint;
export const djvuGetPageCount: (doc: bigint) => number;
export const djvuGetPage: (doc: bigint, pageNo: number) => bigint;
export const djvuDocumentFree: (doc: bigint) => void;
export const djvuPageGetWidth: (page: bigint) => number;
export const djvuPageGetHeight: (page: bigint) => number;
export const djvuPageIsDecodingDone: (page: bigint) => boolean;
export const djvuRenderPage: (
  page: bigint,
  targetWidth: number,
  targetHeight: number,
  sliceX: number,
  sliceY: number,
  sliceWidth: number,
  sliceHeight: number,
  buffer: Uint8Array
) => boolean;
export const djvuPageFree: (page: bigint) => void;
