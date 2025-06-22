@Entry
@Component
struct TestPage {
  @State message: string = '这是个测试页面';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('TestPageHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}