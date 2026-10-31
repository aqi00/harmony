/**
 * libchmcore.so NAPI 模块类型声明
 * 对应 native: entry/src/main/cpp/napi_init.cpp
 */

export const chmOpen: (path: string) => bigint;
export const chmClose: (handle: bigint) => void;
export const chmList: (handle: bigint) => string[];
export const chmResolve: (handle: bigint, path: string) => number[] | null;
export const chmRead: (handle: bigint, path: string, offset: number, length: number) => ArrayBuffer | null;
export const chmReadAll: (handle: bigint, path: string) => ArrayBuffer | null;
