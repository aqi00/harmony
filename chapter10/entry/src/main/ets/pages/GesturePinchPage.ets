@Entry
@Component
struct GesturePinchPage {
  @State message: string = '请双指捏合屏幕';

  build() {
    Column() {
      Text(this.message).fontSize(18).align(Alignment.Top)
        .width('100%').height('100%').padding(5)
        //.scale({x: this.scaleValue, y: this.scaleValue, z: 0}) // 设置组件的缩放大小
        .gesture(
          // fingers为触发捏合的最少手指数。默认为2指
          // distance为触发捏合手势事件的最小识别距离。默认值为5。
          PinchGesture({ fingers: 2, distance: 5 })
            .onActionStart((event: GestureEvent) => {
              console.info('Pinch start')
            })
            .onActionUpdate((event: GestureEvent) => {
              if (event) {
                this.message = `捏合结果如下：\n\t缩放倍率为${event.scale}`
              }
            })
            .onActionEnd((event: GestureEvent) => {
              console.info('Pinch end')
            })
        )
    }
    .width('100%').height('100%')
  }
}