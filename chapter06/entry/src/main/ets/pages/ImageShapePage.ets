@Entry
@Component
struct ImageShapePage {
  @State message: string = 'Hello World';

  build() {
    Scroll() {
      Column() {
        // Shape支持下列图形：Circle（圆形）、Ellipse（椭圆形）、Line（直线）、Polyline（折线）、Polygon（多边形）、Path（路径）、Rect（矩形）
        Text('下面是矩形').fontSize(18).margin(5)
        Rect().width('100%').height(80).fill(Color.Gray)
        Text('下面是方框').fontSize(18).margin(5)
        Rect().width('100%').height(80)
          .strokeWidth(10).stroke(Color.Gray).fill(Color.White)
        Text('下面是圆角矩形').fontSize(18).margin(5)
        Rect().width('100%').height(80).fill(Color.Gray).radius(30)
        Text('下面是圆形').fontSize(18).margin(5)
        Circle().width(80).height(80).fill(Color.Blue)
        Text('下面是圆环').fontSize(18).margin(5)
        Circle().width(80).height(80)
          .strokeWidth(10).stroke(Color.Blue).fill(Color.White)
        Text('下面是椭圆').fontSize(18).margin(5)
        Ellipse().width(160).height(80).fill(Color.Blue)
        Text('下面是Shape').fontSize(18).margin(5)
        Shape() {
          Rect().width('100%').height(80)
            .strokeWidth(10).stroke(Color.Gray).fill(Color.White)
          Circle().width(80).height(80).fill(Color.Blue)
        }.align(Alignment.Center)
      }.width('100%')
    }
    .scrollable(ScrollDirection.Vertical) // 滚动方向
  }
}