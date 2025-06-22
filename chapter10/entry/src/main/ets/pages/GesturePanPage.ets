@Entry
@Component
struct GesturePanPage {
  @State message: string = '请上下左右平移';

  build() {
    Column() {
      Text(this.message).fontSize(18).align(Alignment.Top)
        .width('100%').height('100%').padding(5)
        //.translate({ x: this.offsetX, y: this.offsetY, z: 0 }) // 设置组件的平移距离
        .gesture(
          // direction为触发平移手势的平移方向。默认为ALL。
          // distance为触发平移手势事件的最小平移距离。默认值为5。
          PanGesture({ direction: PanDirection.All, distance: 5 })
            .onActionStart((event: GestureEvent) => {
              console.info('Pan start')
            })
            .onActionUpdate((event: GestureEvent) => {
              if (event) {
                this.message = `平移结果如下：\n\t横坐标偏移为${event.offsetX}\n\t纵坐标偏移为${event.offsetY}`
              }
            })
            .onActionEnd((event: GestureEvent) => {
              console.info('Pan end')
            })
        )
    }
    .width('100%').height('100%')
  }
}