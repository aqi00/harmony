import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('11.1 帧动画')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('图像帧动画').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/FrameAnimationPage' })
          })
        Button('动图动画').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GifAnimationPage' })
          })
        Button('淡入淡出动画').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/FadeAnimationPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('11.2 渐进动画')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('属性动画').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/AttributeAnimationPage' })
          })
        Button('显式动画').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ObviousAnimationPage' })
          })
        Button('关键帧动画').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/KeyFrameAnimationPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('11.3 转场动画')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('页面转场').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TransitionPageOnePage' })
          })
        Button('单组件转场').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TransitionWidgetPage' })
          })
        Button('共享元素转场').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TransitionSharedOnePage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('11.4 实战项目：打牌游戏')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('打牌游戏').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PlayCardPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}