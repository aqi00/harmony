@Entry
@Component
struct ImageResizablePage {
  @State imageNine: Resource = $r('app.media.button_nine'); // 待拉伸的背景图片

  build() {
    Column() {
      // 1、未通过resizable接口拉伸图片
      Stack() {
        Image(this.imageNine).width('100%').height('100%').objectFit(ImageFit.Fill)
        Text('普通图片背景').width('100%').height('100%')
          .fontSize(18).textAlign(TextAlign.Center)
      }.width('100%').height(60).margin({bottom: 5})
      // 2、采用Stack容器方式拉伸图片
      Stack() {
        Image(this.imageNine).width('100%').height('100%').objectFit(ImageFit.Fill)
          .resizable({ slice: { top: 5, left: 5, bottom: 5, right: 5 } })
        Text('九宫格图片背景（Stack容器方式）').width('100%').height('100%')
          .fontSize(18).textAlign(TextAlign.Center)
      }.width('100%').height(60).margin({bottom: 5})
      // 3、直接拉伸Text组件的背景图片
      Text('九宫格图片背景（Text背景方式）').width('100%').height(60)
        .fontSize(18).textAlign(TextAlign.Center)
        .backgroundImage(this.imageNine)
        .backgroundImageSize({width: '100%', height: '100%'})
        .backgroundImageResizable({ slice: { top: 5, left: 5, bottom: 5, right: 5 } })
    }.width('100%').height('100%').padding(5)
  }
}