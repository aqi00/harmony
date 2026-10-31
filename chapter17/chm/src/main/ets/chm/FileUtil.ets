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

  /** 是否是普通文件（对应 Android File#isFile）。 */
  static isFile(path: string): boolean {
    try {
      const stat = fileIo.statSync(path);
      return stat.isFile();
    } catch (e) {
      return false;
    }
  }

  /** 删除文件（不存在则忽略）。 */
  static deleteFile(path: string): void {
    try {
      if (fileIo.accessSync(path)) {
        fileIo.unlinkSync(path);
      }
    } catch (e) {
      // 忽略
    }
  }

  /** 把用户选择器返回的 URI 复制到沙箱路径（对应 Android 复制到 getFilesDir()/books）。 */
  static copyToFile(uri: string, destPath: string): void {
    const src = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    try {
      FileUtil.deleteFile(destPath);
      fileIo.copyFileSync(src.fd, destPath);
    } finally {
      fileIo.closeSync(src);
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

  /** 取路径中的文件名部分。 */
  static baseName(path: string): string {
    const idx = path.lastIndexOf('/');
    return idx >= 0 ? path.substring(idx + 1) : path;
  }
}
