@Entry
@Component
struct GestureRotatePage {
  @State message: string = '请双指旋转屏幕';

  build() {
    Column() {
      Text(this.message).fontSize(18).align(Alignment.Top)
        .width('100%').height('100%').padding(5)
          //.rotate({ angle: this.angle }) // 设置组件的旋转角度
        .gesture(
          // fingers为触发旋转的最少手指数。默认为2指
          // angle为触发旋转手势事件的最小改变度数。默认值为1。
          RotationGesture({ fingers: 2, angle: 1 })
            .onActionStart((event: GestureEvent) => {
              console.info('Rotate start')
            })
            .onActionUpdate((event: GestureEvent) => {
              if (event) {
                this.message = `旋转结果如下：\n\t旋转角度为${event.angle}`
              }
            })
            .onActionEnd((event: GestureEvent) => {
              console.info('Rotate end')
            })
        )
    }
    .width('100%').height('100%')
  }
}