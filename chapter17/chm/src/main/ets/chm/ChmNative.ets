import chmcore from 'libchmcore.so';

/**
 * CHM 原生接口（对应 Android ChmNative 的 JNI 声明）。
 * 句柄以 bigint 传递，文件读写与 LZX 解压都在 libchmcore.so 内完成。
 */
export class ChmNative {
  static open(path: string): bigint {
    return chmcore.chmOpen(path);
  }

  static close(handle: bigint): void {
    chmcore.chmClose(handle);
  }

  /** 返回 CHM 内所有普通文件（以 "/" 开头）。 */
  static list(handle: bigint): string[] {
    return chmcore.chmList(handle);
  }

  /** 返回 [start, length, space, flags]，文件不存在时返回 null。 */
  static resolve(handle: bigint, path: string): number[] | null {
    return chmcore.chmResolve(handle, path);
  }

  static read(handle: bigint, path: string, offset: number, length: number): ArrayBuffer | null {
    return chmcore.chmRead(handle, path, offset, length);
  }

  static readAll(handle: bigint, path: string): ArrayBuffer | null {
    return chmcore.chmReadAll(handle, path);
  }
}
