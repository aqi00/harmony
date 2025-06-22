import { router } from '@kit.ArkUI';

@Entry
@Component
struct SimpleResponsePage {
  router = this.getUIContext().getRouter();
  @State message: string = ''; // 请求消息

  onPageShow() {
    // 获取上个页面传来的参数
    let params = this.router.getParams() as Record<string, Object>;
    if (params != null) {
      this.message = params['msg'] as string
    }
    //this.message = params?.['msg'] as string
    console.info('message: '+this.message)
  }

  build() {
    Column() {
      Text('收到的请求消息为：' + this.message).width('100%').fontSize(17).padding(5)
      Button('返回到请求页面').width('100%').fontSize(17)
        .onClick(() => {
          this.router.back() // 返回到前一个页面
        })
    }
  }
}