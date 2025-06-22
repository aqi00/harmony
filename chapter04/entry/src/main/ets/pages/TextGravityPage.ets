@Entry
@Component
struct TextGravityPage {

  build() {
    Column() {
      Row() {
        Text('靠上靠左对齐').fontSize(20).height('100%').layoutWeight(1)
          // align控制文本在垂直方向的对齐方式，Alignment.Top表示靠上对齐
          // textAlign控制文本在水平方向的对齐方式，TextAlign.Start表示靠左对齐
          .align(Alignment.Top).textAlign(TextAlign.Start)
          .backgroundColor('#ffffaa') // 黄色
        Text('靠上居中对齐').fontSize(20).height('100%').layoutWeight(1)
          .align(Alignment.Top).textAlign(TextAlign.Center)
          .backgroundColor('#00ccff') // 青色
      }.height(100)
      Row() {
        Text('靠右居中对齐').fontSize(20).height('100%').layoutWeight(1)
          .align(Alignment.Center).textAlign(TextAlign.End)
          .backgroundColor('#00ffcc') // 绿色
        Text('靠下靠右对齐').fontSize(20).height('100%').layoutWeight(1)
          .align(Alignment.Bottom).textAlign(TextAlign.End)
          .backgroundColor('#ffaaff') // 紫红
      }.height(100)
    }.width('100%')
  }
}