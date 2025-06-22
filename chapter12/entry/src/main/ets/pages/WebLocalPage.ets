import { webview } from '@kit.ArkWeb';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct WebLocalPage {
  promptAction = this.getUIContext().getPromptAction();
  private webController = new webview.WebviewController(); // 网页控制器
  private localUrl = $rawfile('html/index.html'); // 本地网页文件

  build() {
    Column() {
      Web({ src: this.localUrl, controller: this.webController })
        .width('100%')
          // 网页开始加载
        .onPageBegin((event) => {
          if (event) {
            console.info('onPageBegin url: ' + event.url);
          }
        })
          // 网页加载结束
        .onPageEnd((event) => {
          if (event) {
            console.info('onPageEnd url: ' + event.url);
          }
        })
          // 刷新加载进度
        .onProgressChange((event) => {
          if (event) {
            console.info('newProgress: ' + event.newProgress);
          }
        })
          // 收到网页标题
        .onTitleReceive((event) => {
          if (event) {
            console.info('title: ' + event.title);
          }
        })
          // 收到错误信息
        .onErrorReceive((event) => {
          if (event?.error.getErrorInfo() === 'ERR_INTERNET_DISCONNECTED') {
            this.promptAction.showToast({message: '未连接网络'});
          }
          if (event?.error.getErrorInfo() === 'ERR_CONNECTION_TIMED_OUT') {
            this.promptAction.showToast({message: '网络访问超时'});
          }
        })
    }
    .width('100%')
  }
}