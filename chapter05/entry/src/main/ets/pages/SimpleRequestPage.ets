import { router } from '@kit.ArkUI';

@Entry
@Component
struct SimpleRequestPage {
  router = this.getUIContext().getRouter();
  @State message: string = '你吃饭了吗？来我家吃吧';

  build() {
    Column() {
      Text('待发送的请求消息为：' + this.message).width('100%').fontSize(17).padding(5)
      Button('跳转到应答页面').width('100%').fontSize(17)
        .onClick(() => {
          // pushUrl默认采用Standard标准模式跳转，为Single表示单实例跳转
          this.router.pushUrl({
            url: 'pages/SimpleResponsePage',
            params: { // 传递的参数信息
              msg: this.message
            }
          })
        })
    }
  }
}