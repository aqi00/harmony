@Entry
@Component
struct TextViewPage {
  @State message: string = '你好，世界';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50) // 文字大小
          .fontWeight(FontWeight.Bold) // 字号权重（粗细程度）
        Blank().height(60)
        Text($r('app.string.module_desc'))
          .fontSize(35) // 文字大小
      }
      .width('100%')
    }
  }
}