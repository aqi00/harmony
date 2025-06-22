import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('10.1 返回按键')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('接管返回键').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/EventBackPage' })
          })
        Button('顶部导航').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/NavigationTopPage' })
          })
        Button('底部导航').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/NavigationBottomPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('10.2 事件监控')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('触摸事件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/EventTouchPage' })
          })
        Button('画布绘图').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/Canvas2DDrawPage' })
          })
        Button('手写签名').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/CanvasSignaturePage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('10.4 手势处理')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('双击手势').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GestureTapPage' })
          })
        Button('长按手势').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GestureLongPage' })
          })
        Button('平移手势').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GesturePanPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('滑动手势').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GestureSwipePage' })
          })
        Button('捏合手势').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GesturePinchPage' })
          })
        Button('旋转手势').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GestureRotatePage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('下拉刷新').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PullDownRefreshPage' })
          })
        Button('上拉加载').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PullUpLoadingPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('10.5 实战项目：电子相册')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('电子相册').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'photo/ElectronicAlbumPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}