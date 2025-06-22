import { router } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

@Entry
@Component
struct EmitterSendPage {
  router = this.getUIContext().getRouter();
  @State TAG: string = 'EmitterSendPage';
  @State message: string = '你吃饭了吗？来我家吃吧';

  onPageHide() {
    console.info(this.TAG, 'onPageHide');
    let eventData: emitter.EventData = {
      data: {
        'request_msg': this.message
      }
    }
    emitter.emit('emitter_msg', eventData)
  }

  aboutToDisappear() {
    console.info(this.TAG, 'aboutToDisappear');
    //emitter.off('emitter_msg')
  }

  build() {
    Column() {
      Text('待发送的请求消息为：' + this.message)
        .width('100%').fontSize(17).margin({top: 10})
      Button('跳转到发射器的应答页面')
        .width('100%').fontSize(17).margin({top: 10})
        .onClick(() => {
          // pushUrl默认采用Standard标准模式跳转，为Single表示单实例跳转
          this.router.pushUrl({url: 'pages/EmitterReceivePage'})
        })
    }
  }
}