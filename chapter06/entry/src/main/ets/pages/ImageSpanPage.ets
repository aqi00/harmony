@Entry
@Component
struct ImageSpanPage {

  build() {
    Column() {
      Text() {
        ImageSpan($r('app.media.startIcon'))
          .width(50).height(50).objectFit(ImageFit.Fill)
        Span('ImageSpan表示图像块，Span表示文本块').fontSize(20)
          .decoration({ type: TextDecorationType.None, color: Color.Pink })
      }
    }
    .width('100%')
  }
}