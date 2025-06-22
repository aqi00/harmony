import { router } from '@kit.ArkUI';

@Entry
@Component
struct EventSendPage {
  router = this.getUIContext().getRouter();
  context = this.getUIContext().getHostContext();
  @State TAG: string = 'EventSendPage';
  @State message: string = '你吃饭了吗？来我家吃吧';

  onPageShow() {
    console.info(this.TAG, 'onPageShow');
  }

  onPageHide() {
    console.info(this.TAG, 'onPageHide');
    this.context?.eventHub.emit('event_msg', this.message)
  }

  build() {
    Column() {
      Text('待发送的请求消息为：' + this.message)
        .width('100%').fontSize(17).margin({top: 10})
      Button('跳转到事件总线的应答页面')
        .width('100%').fontSize(17).margin({top: 10})
        .onClick(() => {
          // pushUrl默认采用Standard标准模式跳转，为Single表示单实例跳转
          this.router.pushUrl({url: 'pages/EventReceivePage'})
        })
    }
  }
}