@Entry
@Component
struct GestureSwipePage {
  @State message: string = '请上下左右滑动';

  build() {
    Column() {
      Text(this.message).fontSize(18).align(Alignment.Top)
        .width('100%').height('100%').padding(5)
        .gesture(
          // direction为触发滑动手势的滑动方向。默认为ALL。
          // sppeed为识别滑动的最小速度。默认值为每秒100vp。
          SwipeGesture({ direction: SwipeDirection.All, speed: 100 })
            .onAction((event: GestureEvent) => {
              if (event) {
                this.message = `滑动结果如下：\n\t滑动速度为${event.speed}vp/s\n\t滑动角度为${event.angle}`
              }
            })
        )
    }
    .width('100%').height('100%')
  }
}