@Entry
@Component
struct ViewMarginPage {

  build() {
    Row() {
      Column() {
        Column() {
          Column().width('100%').height('100%')
          .backgroundColor('#ff0000') // 红色
        }
        .backgroundColor('#ffff99') // 黄色
        // Column内部的子组件无法在水平方向留出外部空白
        .margin({ top:20, bottom:20 }) // margin表示与外部的空白距离
        .padding(60) // padding表示内部的留白
      }
      // Row内部的子组件无法在垂直方向留出外部空白
      .margin({ left:20, right:20 }) // margin表示与外部的空白距离
    }
    .width('100%').height(300).backgroundColor('#00ffff') // 青色
  }
}