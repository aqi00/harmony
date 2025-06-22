@Entry
@Component
struct GifAnimationPage {
  @State gifImage: Resource = $r('app.media.happy');
  @State webpImage: Resource = $r('app.media.bezier');
  @State animImage: Resource = this.gifImage;

  build() {
    Column() {
      Row() {
        Button('播放GIF动画').fontSize(17).layoutWeight(1)
          .onClick(() => {
            this.animImage = this.gifImage
          })
        Button('播放WebP动画').fontSize(17).layoutWeight(1)
          .onClick(() => {
            this.animImage = this.webpImage
          })
      }
      Image(this.animImage).height(270).objectFit(ImageFit.Auto)
    }
    .width('100%').height('100%')
  }
}