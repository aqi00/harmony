/** 目录项（扁平结构，level 表示层级，0 为顶层）。对应 Android TocItem。 */
export class TocItem {
  title: string;
  url: string;
  level: number;

  constructor(title: string, url: string, level: number) {
    this.title = title;
    this.url = url;
    this.level = level;
  }

  hasUrl(): boolean {
    return this.url !== null && this.url !== undefined && this.url !== '';
  }
}
