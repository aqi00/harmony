@Entry
@Component
struct ListHorizontalPage {
  private planetArray: SelectOption[] = [
    { value: '水星', icon: $r('app.media.shuixing') },
    { value: '金星', icon: $r('app.media.jinxing') },
    { value: '地球', icon: $r('app.media.diqiu') },
    { value: '火星', icon: $r('app.media.huoxing') },
    { value: '木星', icon: $r('app.media.muxing') },
    { value: '土星', icon: $r('app.media.tuxing') }];

  build() {
    List({ space: 10, initialIndex: 0 }) {
      ForEach(this.planetArray, (item: SelectOption) => {
        ListItem() {
          Column() {
            Image(item.icon).width(50)
            Text(item.value).fontSize(20)
          }
        }
      })
    }
    .listDirection(Axis.Horizontal) // 列表排列方向。默认Vertical表示垂直，为Horizontal表示水平
    .scrollBar(BarState.Off) // 滚动条状态。默认BarState.Auto
    .divider({ strokeWidth: 1, color: Color.Gray, startMargin: 10, endMargin: 10 }) // 每行之间的分界线
    .edgeEffect(EdgeEffect.Fade) // 边缘效果。默认Spring表示边缘拉动呈回弹效果，为Fade表示拉动不回弹但有圆弧阴影
    .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
      console.info(`onScroll scrollState = ScrollState` + scrollState + `, scrollOffset = ` + scrollOffset)
    })
    .height(90).padding(5)
  }
}