@Entry
@Component
struct ViewWeightPage {

  build() {
    Column() {

      Row() {
        // Row内部组件的layoutWeight控制水平方向的宽度权重
        // 下面两个子组件的layoutWeight都为1，表示平分宽度
        Text('横排第一个').fontSize(20).fontColor(Color.White)
          .layoutWeight(1).backgroundColor(Color.Red)
        Text('横排第二个').fontSize(20).fontColor(Color.White)
          .layoutWeight(1).backgroundColor(Color.Orange)
      }.width('100%').margin({bottom:5})
      Column() {
        // Column内部组件的layoutWeight控制垂直方向的高度权重
        // 下面两个子组件的layoutWeight都为1，表示平分高度
        Text('竖排第一个').fontSize(20).fontColor(Color.White)
          .width('100%').layoutWeight(1).backgroundColor(Color.Blue)
        Text('竖排第二个').fontSize(20).fontColor(Color.White)
          .width('100%').layoutWeight(1).backgroundColor(Color.Pink)
      }.width('100%').height(200)
    }
    .width('100%')
  }
}