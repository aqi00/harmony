@Entry
@Component
struct TextSizePage {
  context = this.getUIContext();
  @State message: string = '你好，世界';

  build() {
    Column() {
      // Text('你好，世界（px单位）').fontSize('30px')
      // Text('你好，世界（vp单位）').fontSize('30vp')
      // Text('你好，世界（fp单位）').fontSize('30fp')
      // 注意：设置菜单调整显示大小时，vp和fp都会同步改变文字大小。只有调整字体大小时，才会仅改变fp大小而不改变vp大小
      Text(this.message + '（px单位）').fontSize('30px')
      // 不带单位时，默认为vp单位
      Text(this.message + '（vp单位）').fontSize('30vp')
      // fp允许随系统设置的字体大小而改变大小
      Text(this.message + '（fp单位）').fontSize('30fp')
      Text('1个vp等于'+this.context.vp2px(1)+'个px').fontSize(24)
      Text('1个fp等于'+this.context.fp2px(1)+'个px') .fontSize(24)
      Text(this.message + '（普通）').fontStyle(FontStyle.Normal)
      Text(this.message + '（斜体）').fontStyle(FontStyle.Italic)
      Text(this.message + '（纤细）').fontWeight(FontWeight.Lighter) // Lighter相当于fontWeight=100
      Text(this.message + '（正常）').fontWeight(FontWeight.Normal) // Normal相当于fontWeight=400
      Text(this.message + '（粗体）').fontWeight(FontWeight.Bold) // Bold相当于fontWeight=700
    }
    .width('100%')
  }
}