import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('16.1 界面级一多')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('设备信息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DeviceInfoPage' })
          })
        Button('多语言').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/MultiLanguagePage' })
          })
        Button('显示模式').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ShowModePage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}