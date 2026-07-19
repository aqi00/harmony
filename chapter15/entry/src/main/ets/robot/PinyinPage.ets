import { pinyin4js } from '@ohos/pinyin4js'

@Entry
@Component
struct PinyinPage {
  @State content: string = '歌唱我们亲爱的祖国，从今走向繁荣富强';
  @State need_tone: boolean = true;
  @State result: string = '';

  build() {
    Column() {
      TextArea({text: $$this.content}).width('100%').height(100)
        .fontSize(18).type(TextAreaType.NORMAL).margin(5)
      Button('开始转换').width('100%').fontSize(18)
        .onClick(() => {
          let fomat = this.need_tone ? pinyin4js.WITH_TONE_MARK : pinyin4js.WITHOUT_TONE
          this.result = pinyin4js.convertToPinyinString(this.content, ' ', fomat);
        })
      Row() {
        Checkbox().height(30).width(30).select($$this.need_tone)
        Text('保留声调符号').fontSize(18).margin({ right: 10 })
      }
      .width('100%').justifyContent(FlexAlign.Start).margin(5)
      Text(this.result).width('100%').fontSize(22).margin(5)
    }
    .width('100%').height('100%')

  }
}