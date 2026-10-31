import { ChmNative } from './ChmNative';
import { ChmPath } from './ChmPath';
import { FileUtil } from './FileUtil';

/** CHM 容器（对应 Android ChmFile + chm_lib）。 */
export class ChmFile {
  private filePath: string;
  private handle: bigint = 0n;
  private files: string[] = [];
  private fileSet: Set<string> = new Set<string>();

  private constructor(filePath: string, handle: bigint, files: string[]) {
    this.filePath = filePath;
    this.handle = handle;
    this.files = files;
    this.fileSet = new Set<string>(files);
  }

  static open(path: string): ChmFile {
    if (!FileUtil.isFile(path)) {
      throw new Error('文件不存在：' + path);
    }
    const handle = ChmNative.open(path);
    if (handle === 0n) {
      throw new Error('不是有效的 CHM 文件：' + path);
    }
    const listed = ChmNative.list(handle);
    const files: string[] = [];
    if (listed !== null && listed !== undefined) {
      for (let i = 0; i < listed.length; i++) {
        files.push(listed[i]);
      }
    }
    return new ChmFile(path, handle, files);
  }

  getFilePath(): string {
    return this.filePath;
  }

  getDisplayName(): string {
    return FileUtil.baseName(this.filePath);
  }

  getFiles(): string[] {
    return this.files;
  }

  hasFile(path: string): boolean {
    const normalized = ChmPath.normalize(path);
    if (this.fileSet.has(normalized)) {
      return true;
    }
    return this.resolve(normalized) !== null;
  }

  getSize(path: string): number {
    const info = this.resolve(path);
    return info === null ? -1 : info[1];
  }

  resolve(path: string): number[] | null {
    if (this.handle === 0n) {
      return null;
    }
    return ChmNative.resolve(this.handle, ChmPath.normalize(path));
  }

  /** 读取整个文件；失败返回 null。 */
  read(path: string): Uint8Array | null {
    if (this.handle === 0n) {
      return null;
    }
    const buffer = ChmNative.readAll(this.handle, ChmPath.normalize(path));
    if (buffer === null || buffer === undefined) {
      return null;
    }
    return new Uint8Array(buffer);
  }

  /** 读取部分数据；失败返回 null。 */
  readRange(path: string, offset: number, length: number): Uint8Array | null {
    if (this.handle === 0n) {
      return null;
    }
    const buffer = ChmNative.read(this.handle, ChmPath.normalize(path), offset, length);
    if (buffer === null || buffer === undefined) {
      return null;
    }
    return new Uint8Array(buffer);
  }

  close(): void {
    if (this.handle !== 0n) {
      ChmNative.close(this.handle);
      this.handle = 0n;
    }
  }
}
