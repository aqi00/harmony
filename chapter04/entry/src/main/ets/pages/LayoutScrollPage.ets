@Entry
@Component
struct LayoutScrollPage {
  array: string[] = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];

  build() {
    Column() {
      Text('下面是水平滚动').fontSize(18).height(40).padding(5)
      Scroll() {
        Row() {
          ForEach(this.array, (item: string) => {
            Text(`第${item}项`).width(80).height(80)
              .fontSize(18).textAlign(TextAlign.Center)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal) // 滚动方向
      .scrollBar(BarState.On) // 是否显示滚动条
      .scrollBarWidth(5) // 滚动条的宽度
      .scrollBarColor(Color.Green) // 滚动条的颜色
      Text('下面是垂直滚动').fontSize(18).height(40).padding(5)
      Scroll() {
        Column() {
          ForEach(this.array, (item: string) => {
            Text(`第${item}项`).width('100%').height(100)
              .fontSize(18).textAlign(TextAlign.Center)
          })
        }
      }.layoutWeight(1)
      .scrollable(ScrollDirection.Vertical) // 滚动方向
    }.width('100%')
  }
}