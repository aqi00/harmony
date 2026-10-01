/**
 * 文件工具（替代 Android PathFromUri + getExternalFilesDir 逻辑）。
 * 把 rawfile/sample.djvu 拷到应用沙盒 filesDir/djvu/ 下供 native 打开。
 */
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';

export class FileUtil {

  /** 把 PixelMap 以 JPEG quality=80 保存到 path（parentDir 为其父目录，自动创建）。 */
  public static async saveImage(path: string, pm: image.PixelMap, parentDir: string): Promise<void> {
    FileUtil.ensureDir(parentDir);
    const packer = image.createImagePacker();
    try {
      const opts: image.PackingOption = { format: 'image/jpeg', quality: 80 };
      const data: ArrayBuffer = await packer.packToData(pm, opts);
      const file = fileIo.openSync(path,
        fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
      try {
        fileIo.writeSync(file.fd, data);
      } finally {
        fileIo.closeSync(file);
      }
    } finally {
      packer.release();
    }
  }

  /** 递归创建目录（已存在则跳过）。 */
  public static ensureDir(path: string) {
    try {
      fileIo.accessSync(path);
      return;
    } catch (e) {
      // not exist, create
    }
    const idx = path.lastIndexOf('/');
    const parent = idx > 0 ? path.substring(0, idx) : '';
    if (parent && parent !== path) {
      FileUtil.ensureDir(parent);
    }
    try {
      fileIo.mkdirSync(path);
    } catch (e) {
      // 可能已被并发创建，忽略
    }
  }

  public static exists(path: string) {
    try {
      fileIo.accessSync(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /** 把 number 0..N 补零到 3 位（对齐 Android %03d）。 */
  public static pad3(n: number): string {
    let s = n.toString();
    while (s.length < 3) s = '0' + s;
    return s;
  }

  public static md5Digest(fileName: string): string {
    let md = cryptoFramework.createMd('MD5');
    md.updateSync({ data: new Uint8Array(buffer.from(fileName, 'utf-8').buffer) });
    let digestOutput = md.digestSync();
    let mdstr = buffer.from(digestOutput.data).toString('hex').toUpperCase();
    console.info('md5Digest result: ' + mdstr);
    return mdstr;
  }
}
