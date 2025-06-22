import { router } from '@kit.ArkUI';

@Entry
@Component
struct ParamRequestPage {
  router = this.getUIContext().getRouter();
  @State message: string = '你吃饭了吗？来我家吃吧';
  @State response: string = ''; // 返回消息

  onPageShow() {
    // 获取下个页面返回的参数
    let params = this.router.getParams() as Record<string, Object>;
    this.response = params?.['msg'] as string
    this.response = this.response==null ? '' : this.response
  }

  build() {
    Column() {
      Text('待发送的请求消息为：'+this.message).width('100%').fontSize(17).padding(5)
      Text('收到的应答消息为：'+this.response).width('100%').fontSize(17).padding(5)
      Button('跳转到应答页面').width('100%').fontSize(17)
        .onClick(() => {
          // pushUrl默认采用Standard标准模式跳转，为Single表示单实例跳转
          this.router.pushUrl({
            url: 'pages/ParamResponsePage',
            params: { // 传递的参数信息
              msg: this.message,
              lastUrl: this.router.getState().path + this.router.getState().name
            }
          })
        })
    }
  }
}