import { router } from '@kit.ArkUI';

@Entry
@Component
struct ParamResponsePage {
  router = this.getUIContext().getRouter();
  @State message: string = ''; // 请求消息
  @State response: string = '我吃过了，还是你来我家吃';
  private lastUrl: string = ''; // 上个页面的路径

  onPageShow() {
    // 获取上个页面传来的参数
    let params = this.router.getParams() as Record<string, Object>;
    this.message = params?.['msg'] as string
    this.lastUrl = params?.['lastUrl'] as string
    // console.info('name: '+this.router.getState().name)
    // console.info('index: '+this.router.getState().index)
    // console.info('path: '+this.router.getState().path)
    console.info('message: '+this.message)
  }

  build() {
    Column() {
      Text('收到的请求消息为：' + this.message).width('100%').fontSize(17).padding(5)
      Text('待返回的应答消息为：' + this.response).width('100%').fontSize(17).padding(5)
      Button('返回到请求页面').width('100%').fontSize(17)
        .onClick(() => {
          console.info('lastUrl: '+this.lastUrl)
          this.router.back({
            url: this.lastUrl, // 要返回的页面
            params: { // 传递的参数信息
              msg: this.response
            }
          })
        })
    }
  }
}