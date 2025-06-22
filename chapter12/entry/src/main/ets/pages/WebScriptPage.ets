import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebScriptPage {
  private webController = new webview.WebviewController(); // 网页控制器
  private scriptUrl = $rawfile('raffle/index.html'); // 含JS交互的HTML文件

  // 需要注入到网页的原生方法
  messageFromHtml(value: string) {
    console.info('messageFromHtml: '+value)
    this.getUIContext().showAlertDialog({
      message: '恭喜您抽中了：' + value,
      confirm: {
        value: '确定',
        action: () => {}
      },
      cancel: () => {}
    });
  }

  build() {
    Column() {
      Button('开始抽奖').fontSize(18).width('100%')
        .onClick(() => {
          // 运行网页上的JavaScript脚本。startDraw来自于raffle/js/index.js
          this.webController.runJavaScript('startDraw()');
          // 1、javaScriptProxy只能调用一次，registerJavaScriptProxy可以调用多次；
          // 2、javaScriptProxy在Web组件初始化时调用，registerJavaScriptProxy在Web组件初始化完成后调用
          //this.webController.registerJavaScriptProxy(this.linkObj, 'linkObj', ['messageFromHtml'])
        })
      Web({ src: this.scriptUrl, controller: this.webController })
        .width('100%').aspectRatio(1) // 组件的宽高比例固定为1:1
        .zoomAccess(false) // 是否支持手势进行缩放。默认为true
        .javaScriptAccess(true) // 是否允许执行JavaScript脚本。默认为true
          // 将JavaScript对象注入到window对象中，并在window对象中调用该对象的方法
          // 对象注入之后，网页脚本通过“对象名称.方法名称(……)”来调用App代码
        .javaScriptProxy({
          object: this, // 待注入的对象实例
          name: 'linkObj', // 对象名称，作为index.js中的对象名
          methodList: ['messageFromHtml'], // linkObj对象提供的方法名称列表
          controller: this.webController // 网页控制器
        })
    }
    .width('100%')
  }
}