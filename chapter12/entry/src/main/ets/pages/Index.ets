import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('12.1 HTTP接口')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('JSON串转换').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/JsonConvertPage' })
          })
        Button('GET调用').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/HttpGetPage' })
          })
        Button('POST调用').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/HttpPostPage' })
          })
      }

      Text('12.2 下载上传')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('网络图片').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/HttpImagePage' })
          })
        Button('下载文件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/HttpDownloadPage' })
          })
        Button('上传文件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/HttpUploadPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('12.3 即时通信')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('即时通信文本').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SocketioTextPage' })
          })
        Button('即时通信图片').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SocketioImagePage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('WebSocket').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/WebSocketPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('12.4 网页浏览')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('本地网页').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/WebLocalPage' })
          })
        Button('网页浏览器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/WebRemotePage' })
          })
        Button('网页脚本交互').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/WebScriptPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('12.5 实战项目：多人聊天')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('仿微信的私聊和群聊').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'chat/WeLoginPage' })
          })
      }.padding({top: 3, bottom: 3})
    }
    .width('100%').height('100%')
  }
}