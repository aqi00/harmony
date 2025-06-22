import { router } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

@Entry
@Component
struct EmitterReceivePage {
  router = this.getUIContext().getRouter();
  @State TAG: string = 'EmitterReceivePage';
  @State message: string = ''; // 请求消息

  aboutToAppear() {
    console.info(this.TAG, 'aboutToAppear begin');
    emitter.on('emitter_msg', (event) => {
      if (event != undefined && event.data != undefined) {
        this.message = event.data.request_msg
      }
    })
    console.info(this.TAG, 'aboutToAppear end');
  }

  aboutToDisappear() {
    console.info(this.TAG, 'aboutToDisappear');
    emitter.off('emitter_msg')
  }

  build() {
    Column() {
      Text('收到的请求消息为：' + this.message)
        .width('100%').fontSize(17).margin({top: 10})
      Button('返回到发射器的请求页面')
        .width('100%').fontSize(17).margin({top: 10})
        .onClick(() => {
          this.router.back() // 返回到前一个页面
        })
    }
  }
}