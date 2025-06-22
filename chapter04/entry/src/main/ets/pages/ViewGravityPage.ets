@Entry
@Component
struct ViewGravityPage {

  build() {
    Row() {
      Column() {
        Column().width(100).height(100).backgroundColor('#00ffff') // 青色
      }
      .height(200).layoutWeight(1).margin(10).padding(10)
      .backgroundColor('#ff0000') // 红色
      // alignSelf控制自身位于父节点的对齐方式。
      // 父节点是Column则为水平方向对齐，父节点是Row则为垂直方向对齐
      .alignSelf(ItemAlign.End)
      // alignItems控制子节点的对齐方式。
      // 自身是Column则为水平方向对齐，自身是Row则为垂直方向对齐
      .alignItems(HorizontalAlign.Start)
      Column() {
        Column().width(100).height(100).backgroundColor('#00ffff') // 青色
      }
      .height(200).layoutWeight(1).margin(10).padding(10)
      .backgroundColor('#ff0000') // 红色
      .alignSelf(ItemAlign.Start).alignItems(HorizontalAlign.End)
    }
    .height(300).backgroundColor('#ffff00') // 橙色
  }
}