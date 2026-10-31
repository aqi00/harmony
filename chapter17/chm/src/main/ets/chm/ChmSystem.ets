import { ChmEncoding } from './ChmEncoding';
import { ChmFile } from './ChmFile';
import { ChmPath } from './ChmPath';
import { ChmUrlTable } from './ChmUrlTable';

/** #SYSTEM 字节游标（对应 Android ChmSystem.Cursor）。 */
class SystemCursor {
  private data: Uint8Array;
  private pos: number = 0;

  constructor(data: Uint8Array) {
    this.data = data;
  }

  position(): number {
    return this.pos;
  }

  setPosition(value: number): void {
    this.pos = value;
  }

  remaining(): number {
    return this.data.length - this.pos;
  }

  readU8(): number {
    return this.pos < this.data.length ? (this.data[this.pos++] & 0xFF) : 0;
  }

  readU16(): number {
    const lo = this.readU8();
    const hi = this.readU8();
    return (lo | (hi << 8)) & 0xFFFF;
  }

  readU32(): number {
    const b0 = this.readU8();
    const b1 = this.readU8();
    const b2 = this.readU8();
    const b3 = this.readU8();
    return (b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)) >>> 0;
  }

  /** 读取以 0 结尾的 8 位字符串（保持 latin1 原始字节）。 */
  readCString(end: number): string {
    let out = '';
    while (this.pos < end && this.pos < this.data.length) {
      const b = this.data[this.pos++] & 0xFF;
      if (b === 0) {
        break;
      }
      out += String.fromCharCode(b);
    }
    return out;
  }
}

/**
 * #SYSTEM 元数据解析（移植自 Android ChmSystem / CoolReader chmfmt.cpp 的 CHMSystem）。
 * 提供标题、默认首页、目录文件名与默认编码。
 */
export class ChmSystem {
  private fileVersion: number = 0;
  private contentsFile: string = '';
  private indexFile: string = '';
  private defaultTopic: string = '';
  private title: string = '';
  private language: string = '';
  private defaultFont: string = '';
  private lcid: number = 0;
  private binaryTocId: number = 0;
  private charset: string = ChmEncoding.DEFAULT_ENCODING;

  private constructor() {
  }

  static open(file: ChmFile): ChmSystem {
    const system = new ChmSystem();
    const data = file.read('/#SYSTEM');
    if (data !== null && data.length > 4) {
      system.parse(data);
    }
    system.resolveContentsFile(file);
    return system;
  }

  private parse(data: Uint8Array): void {
    const cursor = new SystemCursor(data);
    this.fileVersion = cursor.readU32();
    while (cursor.remaining() >= 4) {
      const code = cursor.readU16();
      const length = cursor.readU16();
      const end = Math.min(data.length, cursor.position() + length);
      if (end < cursor.position()) {
        break;
      }
      switch (code) {
        case 0:
          this.contentsFile = cursor.readCString(end);
          break;
        case 1:
          this.indexFile = cursor.readCString(end);
          break;
        case 2:
          this.defaultTopic = cursor.readCString(end);
          break;
        case 3:
          this.title = cursor.readCString(end);
          break;
        case 4:
          this.lcid = cursor.readU32();
          cursor.readU32(); // dbcs
          cursor.readU32(); // fullTextSearch
          cursor.readU32(); // hasKLinks
          cursor.readU32(); // hasALinks
          this.charset = ChmEncoding.encodingForCodepage(ChmEncoding.codepageForLcid(this.lcid));
          break;
        case 7:
          if (this.fileVersion > 2) {
            cursor.readU32(); // binary index url table id（暂不使用）
          }
          break;
        case 11:
          if (this.fileVersion > 2) {
            this.binaryTocId = cursor.readU32();
          }
          break;
        case 16:
          this.defaultFont = cursor.readCString(end);
          break;
        default:
          break;
      }
      cursor.setPosition(end);
    }

    if (this.charset === '') {
      this.charset = ChmEncoding.DEFAULT_ENCODING;
    }
    if (this.defaultFont !== '' && this.lcid === 0) {
      const fromFont = ChmEncoding.charsetFromFont(this.defaultFont);
      if (fromFont !== null) {
        this.charset = fromFont;
      }
    }
    this.contentsFile = ChmPath.normalize(ChmSystem.decodeRaw(this.contentsFile, this.charset));
    this.defaultTopic = ChmPath.normalize(ChmSystem.decodeRaw(this.defaultTopic, this.charset));
    this.title = ChmSystem.decodeRaw(this.title, this.charset);
    this.language = ChmSystem.decodeRaw(this.language, this.charset);
  }

  private resolveContentsFile(file: ChmFile): void {
    if (this.contentsFile === '' && this.binaryTocId !== 0) {
      const table = ChmUrlTable.open(file);
      const url = table.urlById(this.binaryTocId);
      if (url !== '') {
        this.contentsFile = ChmPath.normalize(ChmSystem.decodeRaw(url, this.charset));
      }
    }
    if (this.contentsFile === '') {
      this.contentsFile = ChmSystem.findLargestHhc(file);
    }
  }

  private static findLargestHhc(file: ChmFile): string {
    let best = '';
    let bestSize = -1;
    for (const name of file.getFiles()) {
      if (name.toLowerCase().endsWith('.hhc')) {
        const size = file.getSize(name);
        if (size > bestSize) {
          bestSize = size;
          best = name;
        }
      }
    }
    return best;
  }

  /** 把 #SYSTEM 中的 8 位字符串按最终编码解码。 */
  private static decodeRaw(value: string, encoding: string): string {
    if (value === '') {
      return '';
    }
    const bytes = new Uint8Array(value.length);
    for (let i = 0; i < value.length; i++) {
      bytes[i] = value.charCodeAt(i) & 0xFF;
    }
    return ChmEncoding.decode(bytes, encoding);
  }

  getTitle(): string {
    return this.title;
  }

  getDefaultTopic(): string {
    return this.defaultTopic;
  }

  getContentsFile(): string {
    return this.contentsFile;
  }

  getEncodingName(): string {
    return this.charset;
  }

  getCharset(): string {
    return this.charset;
  }

  getLcid(): number {
    return this.lcid;
  }

  getDefaultFont(): string {
    return this.defaultFont;
  }

  getLanguage(): string {
    return this.language;
  }
}
