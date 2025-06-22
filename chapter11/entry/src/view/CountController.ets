
@Component
export struct CountController {
  @Link quantity: number; // 卡片数量

  build() {
    Column() {
      Row() {
        Text('数量').fontSize(18)
        Text(this.quantity.toFixed(0)).fontSize(18)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%') .margin({ top: 4 })

      Slider( {
        value: $$this.quantity,
        min: 3,
        max: 6,
        step: 1,
        style: SliderStyle.InSet
      } )
        .blockColor(Color.White).selectedColor(Color.Blue)
        .margin({ top: 5 }).showSteps(true).trackThickness(20)
    }
    .width(336).height(97).margin({ bottom: 48 })
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .borderRadius(24).backgroundColor(Color.White)
  }
}