@Entry
@Component
struct GestureTapPage {
  @State message: string = '请双击屏幕';

  build() {
    Column() {
      Text(this.message).fontSize(18).align(Alignment.Top)
        .width('100%').height('100%').padding(5)
        .gesture(
          // fingers为触发双击的最少手指数。默认为1指
          // count为识别的连续点击次数。默认为1表示单击，为2时表示双击
          TapGesture({ fingers: 1, count: 2 })
            .onAction((event: GestureEvent) => {
              if (event) {
                this.message = '双击结果如下：'
                for (let finger of event.fingerList) {
                  this.message = `${this.message}\n手指${finger.id}双击位置的横坐标为${finger.localX}，纵坐标为${finger.localY}`
                }
              }
            })
        )
    }
    .width('100%').height('100%')
  }
}