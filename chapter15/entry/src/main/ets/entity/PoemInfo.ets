import { pinyin4js } from '@ohos/pinyin4js'

export class PoemInfo {
  id: number // 编号
  title: string // 诗歌标题
  author: string // 诗歌作者
  dynasty: string // 作者朝代
  content: string // 诗歌内容
  pinyin: string // 标题的拼音

  constructor(title: string, author: string, dynasty: string, content: string) {
    this.id = -1
    this.title = title
    this.author = author
    this.dynasty = dynasty
    this.content = content
    let splits: string[] = title.split('·')
    let shortTitle = splits.length > 1 ? splits[1] : title
    let hanzi = shortTitle.length <= 4 ? shortTitle : shortTitle.substring(0, 4)
    this.pinyin = pinyin4js.convertToPinyinString(hanzi, '', pinyin4js.WITHOUT_TONE);
  }
}