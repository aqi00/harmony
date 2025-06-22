import { router } from '@kit.ArkUI';
import { GlobalThis } from '../utils/GlobalThis';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  aboutToAppear(): void {
    GlobalThis.getInstance().setUIContext('ui_context', this.getUIContext());
  }

  build() {
    Column() {
      Text('9.1 权限管控')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('振动器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/VibratorPage' })
          })
        Button('创建日历账户').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/CalendarCreatePage' })
          })
        Button('添加日程').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/EventAddPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('9.2 消息通知')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('简单消息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/NotificationSimplePage' })
          })
        Button('通知跳转').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/NotificationJumpPage' })
          })
        Button('渠道消息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/NotificationChannelPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('9.3 后台处理')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('延迟处理').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DelayIntervalPage' })
          })
        Button('后台代理提醒').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/NotificationReminderPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('短时任务').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ShortTaskPage' })
          })
        Button('长时任务').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LongTaskPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('9.4 实战项目：后台录音')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('仿录音笔').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/RecorderPenPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}