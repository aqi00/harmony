@Entry
@Component
struct StackPage {

  build() {
    // Stack的子节点默认在水平方向和垂直方向都居中
    Stack() {
      Column().width('100%').height('100%')
        .backgroundColor('#ff0000') // 红色
      Column().width('70%').height('70%')
        .backgroundColor('#ff9900') // 橙色
      Column().width('40%').height('40%')
        .backgroundColor('#00ffff') // 青色
    }.height(300)
  }
}