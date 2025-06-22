import { router } from '@kit.ArkUI';

@Entry
@Component
struct EventReceivePage {
  router = this.getUIContext().getRouter();
  context = this.getUIContext().getHostContext();
  @State TAG: string = 'EventReceivePage';
  @State message: string = ''; // 请求消息

  aboutToAppear() {
    console.info(this.TAG, 'aboutToAppear');
    this.context?.eventHub.on('event_msg', (message: string) => {
      this.message = message
      console.info('message: '+this.message)
    })
  }

  aboutToDisappear() {
    console.info(this.TAG, 'aboutToDisappear');
    this.context?.eventHub.off('event_msg');
  }

  build() {
    Column() {
      Text('收到的请求消息为：' + this.message)
        .width('100%').fontSize(17).margin({top: 10})
      Button('返回到事件总线的请求页面')
        .width('100%').fontSize(17).margin({top: 10})
        .onClick(() => {
          this.router.back() // 返回到前一个页面
        })
    }
  }
}