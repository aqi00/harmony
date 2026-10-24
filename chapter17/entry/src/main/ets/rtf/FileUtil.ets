/**
 * 文件工具（对应 Android 侧的 FileOutputStream / FileInputStream / getFilesDir 等）。
 */
import { fileIo } from '@kit.CoreFileKit';

export class FileUtil {
  /** 递归创建目录（已存在则跳过）。 */
  static ensureDir(path: string): void {
    try {
      if (fileIo.accessSync(path)) {
        return;
      }
    } catch (e) {
      // 目录不存在，继续创建
    }
    const idx = path.lastIndexOf('/');
    const parent = idx > 0 ? path.substring(0, idx) : '';
    if (parent !== '' && parent !== path) {
      FileUtil.ensureDir(parent);
    }
    try {
      fileIo.mkdirSync(path);
    } catch (e) {
      // 并发创建时忽略
    }
  }

  static exists(path: string): boolean {
    try {
      fileIo.accessSync(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /** 覆盖写入字节（对应 Android FileOutputStream#write）。 */
  static writeBytes(path: string, data: Uint8Array): void {
    const file = fileIo.openSync(path,
      fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
    try {
      if (data.length > 0) {
        fileIo.writeSync(file.fd, data.buffer as ArrayBuffer);
      }
    } finally {
      fileIo.closeSync(file);
    }
  }

  /** 覆盖写入文本（UTF-8，对应 Android PrintWriter 写 HTML）。 */
  static writeText(path: string, text: string): void {
    const file = fileIo.openSync(path,
      fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
    try {
      fileIo.writeSync(file.fd, text);
    } finally {
      fileIo.closeSync(file);
    }
  }

  /** 读取整个文件为字节数组。 */
  static readBytes(path: string): Uint8Array {
    const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
    try {
      const size: number = fileIo.statSync(file.fd).size;
      const data = new Uint8Array(size);
      if (size > 0) {
        fileIo.readSync(file.fd, data.buffer as ArrayBuffer);
      }
      return data;
    } finally {
      fileIo.closeSync(file);
    }
  }

  /** 读取整个文件（按 URI，用于「打开文件」选中的文档）。 */
  static readBytesByUri(uri: string): Uint8Array {
    const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    try {
      const size: number = fileIo.statSync(file.fd).size;
      const data = new Uint8Array(size);
      if (size > 0) {
        fileIo.readSync(file.fd, data.buffer as ArrayBuffer);
      }
      return data;
    } finally {
      fileIo.closeSync(file);
    }
  }

  /** 取路径中的文件名部分。 */
  static baseName(path: string): string {
    const idx = path.lastIndexOf('/');
    return idx >= 0 ? path.substring(idx + 1) : path;
  }
}
