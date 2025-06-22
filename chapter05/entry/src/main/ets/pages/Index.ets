import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('5.1 页面跳转')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('去注册').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GoRegisterPage' })
          })
        Button('去登录').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GoLoginPage' })
          })
        Button('去跳转').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/JumpFirstPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('5.2 传递消息')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('发送请求参数').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SimpleRequestPage' })
          })
        Button('返回应答参数').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ParamRequestPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('事件总线中转消息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/EventSendPage' })
          })
        Button('发射器中转消息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/EmitterSendPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('5.3 外部跳转')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('显式意图').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/WantExplicitPage' })
          })
        Button('隐式意图').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/WantImplicitPage' })
          })
        Button('拨号通讯录').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/WantSpecialPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}