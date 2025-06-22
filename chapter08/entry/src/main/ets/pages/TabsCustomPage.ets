@Entry
@Component
struct TabsCustomPage {
  @State current: number = 0; // 当前页签的序号

  // 通过比较this.current与index的相等关系，判断某个页签是否为被选中的页签
  @Builder tabBuilder(index: number, name: string) {
    Column() {
      Text(name).fontSize(20).margin({ top: 12, bottom: 8})
        .fontColor(this.current == index ? Color.Blue : Color.Gray)
        .fontWeight(this.current == index ? FontWeight.Bolder : FontWeight.Normal)
      Divider().strokeWidth(5).color(Color.Blue)
        .opacity(this.current == index ? 1 : 0) // 1表示不透明，0表示透明
    }.width('100%')
  }

  build() {
    // barPosition取值Start表示放在开头，取值End表示放在末尾
    Tabs({ barPosition: BarPosition.Start, index: $$this.current }) {
      TabContent() {
        Column().width('100%').height('100%').backgroundColor(Color.Green)
      }.tabBar(this.tabBuilder(0, '绿色'))

      TabContent() {
        Column().width('100%').height('100%').backgroundColor(Color.Blue)
      }.tabBar(this.tabBuilder(1, '蓝色'))

      TabContent() {
        Column().width('100%').height('100%').backgroundColor(Color.Yellow)
      }.tabBar(this.tabBuilder(2, '黄色'))

      TabContent() {
        Column().width('100%').height('100%').backgroundColor(Color.Pink)
      }.tabBar(this.tabBuilder(3, '粉色'))
    }
    .vertical(false) // 是否垂直布局。默认为false表示水平布局，为true表示垂直布局
    .barMode(BarMode.Fixed) // 页签栏模式。默认Fixed表示固定，为Scrollable表示允许滑动
    .barWidth('100%') // 页签栏的宽度
    .barHeight(50) // 页签栏的高度
    .animationDuration(400) // 页签切换动画的时长
    .width('100%').height('100%')
  }
}