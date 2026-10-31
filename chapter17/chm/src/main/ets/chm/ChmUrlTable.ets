import { ChmFile } from './ChmFile';

/**
 * #URLTBL / #URLSTR 解析（移植自 Android ChmUrlTable）。
 * 用于读取 #SYSTEM 中二进制 TOC/Index 对应的 URL。
 */
export class ChmUrlTable {
  private static readonly BLOCK_SIZE: number = 0x1000;
  private static readonly TABLE_RECORD_COUNT: number = 341;

  private idToStrOffset: Map<number, number> = new Map<number, number>();
  private offsetToUrl: Map<number, string> = new Map<number, string>();

  static open(file: ChmFile): ChmUrlTable {
    const table = new ChmUrlTable();
    const strings = file.read('/#URLSTR');
    const entries = file.read('/#URLTBL');
    if (strings !== null) {
      table.parseStrings(strings);
    }
    if (entries !== null) {
      table.parseTable(entries);
    }
    return table;
  }

  urlById(id: number): string {
    const strOffset = this.idToStrOffset.get(id);
    if (strOffset === undefined) {
      return '';
    }
    const url = this.offsetToUrl.get(strOffset);
    return url === undefined ? '' : url;
  }

  private parseStrings(data: Uint8Array): void {
    let pos = 1; // 跳过首字节，与 Android 实现保持一致
    let blockBase = 1;
    while (pos < data.length) {
      const size = Math.min(ChmUrlTable.BLOCK_SIZE, data.length - pos);
      this.decodeStringBlock(data, pos, size, blockBase);
      pos += size;
      blockBase += size;
    }
  }

  private decodeStringBlock(data: Uint8Array, pos: number, size: number, blockBase: number): void {
    let index = pos;
    const end = pos + size;
    while (index + 8 < end) {
      const offset = blockBase + (index - pos);
      index += 8; // urlOffset + frameOffset
      let value = '';
      while (index < end) {
        const b = data[index++];
        if (b === 0) {
          break;
        }
        value += String.fromCharCode(b);
      }
      this.offsetToUrl.set(offset, value);
    }
  }

  private parseTable(data: Uint8Array): void {
    let pos = 0;
    while (pos < data.length) {
      const size = Math.min(ChmUrlTable.BLOCK_SIZE, data.length - pos);
      let index = pos;
      const end = pos + size;
      for (let i = 0; i < ChmUrlTable.TABLE_RECORD_COUNT && index + 12 <= end; i++) {
        const id = ChmUrlTable.readU32(data, index);
        index += 8; // id + topicsIndex
        const strOffset = ChmUrlTable.readU32(data, index);
        index += 4;
        this.idToStrOffset.set(id, strOffset);
      }
      pos += size;
    }
  }

  private static readU32(data: Uint8Array, pos: number): number {
    return (data[pos] | (data[pos + 1] << 8) | (data[pos + 2] << 16) | (data[pos + 3] << 24)) >>> 0;
  }
}
