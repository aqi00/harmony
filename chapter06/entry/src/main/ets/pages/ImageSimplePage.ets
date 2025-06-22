@Entry
@Component
struct ImageSimplePage {

  build() {
    Column() {
      Row() {
        Text('左边').fontSize(18)
        Blank(150).color(Color.Gray)
        Text('右边').fontSize(18)
      }.margin(5)
      Text('上边').fontSize(18)
      Divider().vertical(false).color(Color.Black).strokeWidth(5)
      Text('下边').fontSize(18)
    }.width('100%')
  }
}