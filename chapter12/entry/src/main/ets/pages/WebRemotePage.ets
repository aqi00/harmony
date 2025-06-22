import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct WebRemotePage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State isLoading: boolean = true; // 是否正在加载
  @State progressVal: number = 0; // 加载进度值
  private webController = new webview.WebviewController(); // 网页控制器
  @State remoteUrl: string = 'https://qq.com/'; // 网页链接

  build() {
    Stack() {
      Column() {
        Row() {
          TextInput({ text: $$this.remoteUrl })
            .layoutWeight(1).height(40).margin(5).fontSize(18)
            //.type(InputType.Normal)
          Image($r('app.media.icon_go'))
            .width(40).height(40).objectFit(ImageFit.Contain)
            .onClick(() => {
              this.webController.loadUrl(this.remoteUrl) // 加载URL地址
            })
        }.margin(5)
        Web({ src: this.remoteUrl, controller: this.webController })
          .width('100%').layoutWeight(1)
          // .imageAccess(true) // 是否允许自动加载图片资源。默认为true
          // .onlineImageAccess(true) // 是否允许从网络加载图片资源。默认为true
          // .javaScriptAccess(true) // 是否允许执行JavaScript脚本。默认为true
          // .zoomAccess(true) // 是否支持手势进行缩放。默认为true
          // .fileAccess(true) // 是否开启应用文件系统的访问。默认为false
          // .cacheMode(CacheMode.Default) // 设置缓存模式。默认为Default
          .domStorageAccess(true) // 是否开启文档对象模型存储接口。默认为false
          // .mixedMode(MixedMode.None) // 是否允许加载http和https的混合内容。默认为None
          // .geolocationAccess(true) // 是否开启获取地理位置权限。默认为true
          // .databaseAccess(true) // 是否开启数据库存储API权限。默认为false
          // .mediaPlayGestureAccess(true) // 有声视频播放是否需要用户手动点击。默认为true
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
              this.progressVal = event.newProgress
              if (event.newProgress === 100) {
                this.isLoading = false // 已加载完成
              } else {
                this.isLoading = true // 未加载完成
              }
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
        Row() {
          Image($r('app.media.icon_back'))
            .height('100%').layoutWeight(1).objectFit(ImageFit.Contain)
            .onClick(() => {
              if (this.webController.accessBackward()) {
              } else {
                this.promptAction.showToast({message: '已经是最后一页了'})
              }
              this.webController.backward() // 退后一页
            })
          Image($r('app.media.icon_forward'))
            .height('100%').layoutWeight(1).objectFit(ImageFit.Contain)
            .onClick(() => {
              if (this.webController.accessForward()) {
                this.webController.forward() // 向前一页
              } else {
                this.promptAction.showToast({message: '已经是最前一页了'})
              }
            })
          Image($r('app.media.icon_refresh'))
            .height('100%').layoutWeight(1).objectFit(ImageFit.Contain)
            .onClick(() => {
              this.webController.refresh() // 刷新当前页
            })
          Image($r('app.media.icon_close'))
            .height('100%').layoutWeight(1).objectFit(ImageFit.Contain)
            .onClick(() => {
              this.router.back() // 返回到前一个页面
            })
        }.height(40).margin(5)
      }
      .width('100%').height('100%')
      if (this.isLoading) { // 正在加载时显示进度条
        Progress({ value: 0, total: 100, type: ProgressType.ScaleRing })
          .position({ x: '40%', y: '30%' }).width(80)//.zIndex(1)
          .color(Color.Grey).value(this.progressVal)
          .style({ strokeWidth: 15, scaleCount: 15, scaleWidth: 5 })
      }
    }
    .width('100%').height('100%')
  }
}