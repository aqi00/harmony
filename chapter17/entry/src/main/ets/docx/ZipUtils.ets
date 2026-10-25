import { fileIo } from "@kit.CoreFileKit";
import { zlib } from "@kit.BasicServicesKit";
import { util } from "@kit.ArkTS";

/**
 * 鸿蒙原生 ZIP 解析器 —— 不依赖任何第三方库。
 *
 * 鸿蒙 ohpm 仓库里没有 jszip（那是 npm 包），@ohos.zlib 提供的 zlib.uncompress2()
 * 是 async Promise，需要先手动解析 ZIP Local File Header 拿到 uncompressedSize 预分配目标 buffer。
 *
 * docx 是 ZIP 容器，内部主要是 Deflate（compressMethod=8）和 Stored（compressMethod=0）两种压缩方式。
 */
export class ZipUtils {

  /** 用 openSync + readSync 把整个文件读成 Uint8Array。 */
  private static readAllBytes(path: string): Uint8Array {
    const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
    try {
      const size: number = fileIo.statSync(file.fd).size;
      const buf = new ArrayBuffer(size);
      fileIo.readSync(file.fd, buf);
      return new Uint8Array(buf);
    } finally {
      fileIo.closeSync(file);
    }
  }

  /** 递归创建目录（同步）。 */
  static mkdirs(dirPath: string): void {
    try {
      const stat = fileIo.statSync(dirPath);
      if (stat.isDirectory()) return;
    } catch (e) { /* not exists */ }
    const lastSlash = dirPath.lastIndexOf('/');
    if (lastSlash > 0) {
      ZipUtils.mkdirs(dirPath.substring(0, lastSlash));
    }
    try { fileIo.mkdirSync(dirPath); } catch (e) { /* exists */ }
  }

  /** 解压 docx（ZIP）到指定目录（async，因为解压用 zlib.uncompress2）。 */
  static async unzipToDir(docxPath: string, targetDir: string): Promise<string[]> {
    console.info('unzipToDir.mkdirs targetDir: ', targetDir);
    ZipUtils.mkdirs(targetDir);
    const fileData: Uint8Array = ZipUtils.readAllBytes(docxPath);
    const entries: string[] = [];

    let offset: number = 0;

    while (offset + 30 <= fileData.length) {
      const sig = ZipUtils.readUint32(fileData, offset);
      if (sig !== 0x04034b50) break;

      const flags = ZipUtils.readUint16(fileData, offset + 6);
      const method = ZipUtils.readUint16(fileData, offset + 8);
      const compressedSize = ZipUtils.readUint32(fileData, offset + 18);
      const uncompressedSize = ZipUtils.readUint32(fileData, offset + 22);
      const nameLen = ZipUtils.readUint16(fileData, offset + 26);
      const extraLen = ZipUtils.readUint16(fileData, offset + 28);

      let dataStart = offset + 30 + nameLen + extraLen;
      let dataLen = compressedSize;
      if (compressedSize === 0 && (flags & 0x08) !== 0) {
        let no = dataStart;
        while (no + 4 <= fileData.length) {
          const s = ZipUtils.readUint32(fileData, no);
          if (s === 0x04034b50 || s === 0x02014b50 || s === 0x06054b50) break;
          no++;
        }
        dataLen = no - dataStart;
      }

      const nameBytes = fileData.subarray(offset + 30, offset + 30 + nameLen);
      const entryName = ZipUtils.bytesToString(nameBytes);
      offset = dataStart + dataLen;

      if (entryName.endsWith('/')) continue;
      entries.push(entryName);

      const outPath = targetDir + '/' + entryName;
      const lastSlash = outPath.lastIndexOf('/');
      if (lastSlash > 0) {
        ZipUtils.mkdirs(outPath.substring(0, lastSlash));
      }

      const rawBytes = fileData.subarray(dataStart, dataStart + dataLen);
      let outBytes: Uint8Array | null = null;
      if (method === 0) {
        outBytes = rawBytes;
      } else if (method === 8) {
        outBytes = await ZipUtils.doInflate(rawBytes, uncompressedSize);
        if (!outBytes) continue;
      } else {
        console.info('ZipUtils skip unsupported method', method, entryName);
        continue;
      }

      try {
        const file = fileIo.openSync(outPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        fileIo.writeSync(file.fd, outBytes.buffer.slice(0, outBytes.byteLength));
        fileIo.closeSync(file);
      } catch (e) {
        console.info('ZipUtils write failed', outPath, String(e));
      }
    }

    console.info('ZipUtils.unzip total entries =', entries.length);
    return entries;
  }

  /** 直接获取 zip 内某条目为 Uint8Array。 */
  static async getEntryBytes(docxPath: string, targetEntry: string): Promise<Uint8Array | null> {
    const fileData: Uint8Array = ZipUtils.readAllBytes(docxPath);
    let offset: number = 0;

    while (offset + 30 <= fileData.length) {
      const sig = ZipUtils.readUint32(fileData, offset);
      if (sig !== 0x04034b50) break;

      const flags = ZipUtils.readUint16(fileData, offset + 6);
      const method = ZipUtils.readUint16(fileData, offset + 8);
      const compressedSize = ZipUtils.readUint32(fileData, offset + 18);
      const uncompressedSize = ZipUtils.readUint32(fileData, offset + 22);
      const nameLen = ZipUtils.readUint16(fileData, offset + 26);
      const extraLen = ZipUtils.readUint16(fileData, offset + 28);

      let dataStart = offset + 30 + nameLen + extraLen;
      let dataLen = compressedSize;
      if (compressedSize === 0 && (flags & 0x08) !== 0) {
        let no = dataStart;
        while (no + 4 <= fileData.length) {
          const s = ZipUtils.readUint32(fileData, no);
          if (s === 0x04034b50 || s === 0x02014b50 || s === 0x06054b50) break;
          no++;
        }
        dataLen = no - dataStart;
      }

      const nameBytes = fileData.subarray(offset + 30, offset + 30 + nameLen);
      const entryName = ZipUtils.bytesToString(nameBytes);

      if (entryName === targetEntry) {
        const rawBytes = fileData.subarray(dataStart, dataStart + dataLen);
        if (method === 0) return rawBytes;
        if (method === 8) return await ZipUtils.doInflate(rawBytes, uncompressedSize);
        return null;
      }

      offset = dataStart + dataLen;
    }
    return null;
  }

  /** 直接获取 zip 内某条目内容为 UTF-8 文本。 */
  static async getEntryText(docxPath: string, targetEntry: string): Promise<string> {
    const bytes = await ZipUtils.getEntryBytes(docxPath, targetEntry);
    if (!bytes) return '';
    return ZipUtils.bytesToString(bytes);
  }

  /**
   * 解压 ZIP 里的 raw deflate 数据（windowBits=-15）。
   *
   * ZIP 容器里的 deflate 是 raw deflate（没有 zlib header/adler32），
   * 鸿蒙 zlib.uncompress2 默认用 zlib 格式（windowBits=15），会报 17800005。
   * 所以改用 inflateInit2(strm, -15) + inflate + inflateEnd 链手动解压。
   */
  private static async doInflate(raw: Uint8Array, expectedSize: number): Promise<Uint8Array | null> {
    try {
      const sourceBuf: ArrayBuffer = raw.buffer.slice(raw.byteOffset, raw.byteOffset + raw.byteLength);
      const destSize = expectedSize > 0 ? expectedSize : raw.length * 10 + 4096;
      const destBuf = new ArrayBuffer(destSize);

      const zip = zlib.createZipSync();
      const strm: zlib.ZStream = {
        nextIn: sourceBuf,
        availableIn: raw.byteLength,
        totalIn: 0,
        nextOut: destBuf,
        availableOut: destSize,
        totalOut: 0,
        dataType: 0,
        adler: 0,
      };

      // windowBits=-15 表示 raw deflate（没有 zlib header）
      const initResult = await zip.inflateInit2(strm, -15);
      if (initResult !== zlib.ReturnStatus.OK) {
        console.info('ZipUtils.inflateInit2 failed:', initResult);
        return null;
      }

      const inflateResult = await zip.inflate(strm, zlib.CompressFlushMode.FINISH);
      console.info('ZipUtils.inflate result=', inflateResult,
        ' totalOut=', strm.totalOut,
        ' expectedSize=', expectedSize,
        ' rawLen=', raw.byteLength);

      await zip.inflateEnd(strm);

      // inflate 返回 STREAM_END(1) 或 OK(0) 都视为成功
      if (inflateResult !== zlib.ReturnStatus.STREAM_END && inflateResult !== zlib.ReturnStatus.OK) {
        console.info('ZipUtils.inflate failed:', inflateResult);
        return null;
      }

      // ArkTS native 绑定不回写 strm.totalOut，所以不能用它的值。
      // 优先信任 ZIP header 里的 expectedSize（本来就是准确值），
      // expectedSize=0 时再兜底扫描 destBuf 找最后一个非零字节。
      let outLen = expectedSize > 0 ? expectedSize : (strm.totalOut ?? 0);
      if (outLen === 0) {
        const u8 = new Uint8Array(destBuf);
        for (let i = destBuf.byteLength - 1; i >= 0; i--) {
          if (u8[i] !== 0) {
            outLen = i + 1;
            break;
          }
        }
      }
      if (outLen === 0) {
        console.info('ZipUtils.inflate produced 0 bytes');
        return null;
      }
      return new Uint8Array(destBuf).subarray(0, outLen);
    } catch (e) {
      console.info('ZipUtils.doInflate failed', String(e));
      return null;
    }
  }

  // ---------- 字节工具 ----------

  private static readUint32(buf: Uint8Array, offset: number): number {
    return (buf[offset] | (buf[offset + 1] << 8) |
            (buf[offset + 2] << 16) | (buf[offset + 3] << 24)) >>> 0;
  }

  private static readUint16(buf: Uint8Array, offset: number): number {
    return (buf[offset] | (buf[offset + 1] << 8)) & 0xffff;
  }

  private static bytesToString(bytes: Uint8Array): string {
    const decoder = util.TextDecoder.create('utf-8');
    try {
      return decoder.decodeToString(bytes);
    } catch (e) {
      return decoder.decode(bytes);
    }
  }
}
