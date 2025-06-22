@Entry
@Component
struct GestureLongPage {
  @State message: string = '请长按屏幕';

  build() {
    Column() {
      Text(this.message).fontSize(18).align(Alignment.Top)
        .width('100%').height('100%').padding(5)
        .gesture(
          // fingers为触发长按的最少手指数。默认为1指
          // repeat表示是否连续触发事件回调。默认false
          LongPressGesture({ fingers: 1, repeat: false })
            .onAction((event: GestureEvent) => {
              if (event) {
                this.message = '长按结果如下：'
                for (let finger of event.fingerList) {
                  this.message = `${this.message}\n手指${finger.id}长按位置的横坐标为${finger.localX}，纵坐标为${finger.localY}`
                }
              }
            })
            .onActionEnd((event: GestureEvent) => {
              this.message = this.message + '\n长按结束'
            })
        )
    }
    .width('100%').height('100%')
  }
}