@Entry
@Component
struct EventTouchPage {
  private touchTypeArray: string[] = ['按下', '提起', '移动', '取消'];
  private sourceArray: string[] = ['未知', '鼠标', '触摸屏'];
  @State message: string = '请在屏幕上触摸滑动'; // 触摸结果

  build() {
    Column() {
      Text(this.message)
        .width('100%').height('100%').fontSize(18).padding(10)
        .align(Alignment.Top).textAlign(TextAlign.Start)
        .onTouch((event?: TouchEvent) => {
          if (event != undefined) {
            this.message = `当前事件类型为${this.touchTypeArray[event.type]}，触摸来源为${this.sourceArray[event.source]}。`
            //this.message = `${this.message}\n横坐标为${event.tiltX}，纵坐标为${event.tiltY}，压力值为${event.pressure}`
            if (event.touches != undefined) {
              for (let item of event.touches) {
                this.message = `${this.message}\n触摸点${item.id}的类型为${this.touchTypeArray[item.type]}，横坐标为${item.x}，纵坐标为${item.y}`
              }
            }
          }
        })
    }
    .width('100%').height('100%')
  }
}