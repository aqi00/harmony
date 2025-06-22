@Entry
@Component
struct ButtonTypePage {

  build() {
    Column() {
      Button('默认按钮').fontSize(18).margin(2).height(60)
      Button('普通按钮').fontSize(18).margin(2).height(60)
        .type(ButtonType.Normal) // 普通按钮为四个方角
      Button('胶囊按钮').fontSize(18).margin(2).height(60)
        .type(ButtonType.Capsule) // 胶囊按钮为四个圆角
      Button('圆角矩形按钮').fontSize(18).margin(2).height(60)
        .type(ButtonType.ROUNDED_RECTANGLE) // 圆角矩形按钮
      Button('圆形按钮指定高度').fontSize(18).margin(2).height(200)
        .type(ButtonType.Circle) // 圆形按钮为正圆形

    }
    .width('100%')
  }
}