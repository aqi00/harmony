import { common } from '@kit.AbilityKit'
import { webview } from '@kit.ArkWeb'

import { BridgeUtil } from './BridgeUtil'
import { BridgeController } from './BridgeController'
import { ExtendAction } from './CommonTypes'

@Component
export struct BridgeWeb {
  // 接收外部参数
  @Prop src: string | Resource
  @Prop bridge: BridgeController
  // 接收注册回调
  onRegister: (action: ExtendAction) => void = (_action: ExtendAction): void => {}
  private controller: webview.WebviewController = new webview.WebviewController()
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext
  private toLoadJs: string = 'WebViewJavascriptBridge.js';

  aboutToAppear(): void {
    this.bridge.setNativeController(this.controller)
    // 将自身方法注册给父组件
    this.onRegister((action: string): void => {
      this.controller.runJavaScriptExt(action).catch((err: BusinessError) => {
        console.error('runJavaScriptExt failed with err: ' + JSON.stringify(err));
      });
    })
  }

  build() {
    Column() {
      Web({ src: this.src, controller: this.controller })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .imageAccess(true)
        .onlineImageAccess(true)
        // 扩展到顶部安全区域（状态栏），使背景色填充状态栏区域
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onPageBegin((event: OnPageBeginEvent): void => {
          if (event) {
          }
        })
        .onPageEnd((event: OnPageEndEvent): void => {
          if (event) {
            if (this.toLoadJs != null) {
              this.bridge.webViewLoadLocalJs(this.context, this.toLoadJs);
            }
            if (this.bridge.getStartupMessage() != null) {
              for (let msg of this.bridge.getStartupMessage()) {
                this.bridge.dispatchMessage(msg);
              }
              this.bridge.setStartupMessage([]);
            }
          }
        })
        .onInterceptRequest((event) => {
          if (event) {
            let url = event.request.getRequestUrl()
            url = decodeURIComponent(url)
            console.info('url: ' + url)
            if (url.startsWith(BridgeUtil.YY_RETURN_DATA)) {
              this.bridge.handlerReturnData(url)
            } else if (url.startsWith(BridgeUtil.YY_OVERRIDE_SCHEMA)) {
              this.bridge.flushMessageQueue()
            }
          }
          return null
        })
        .onProgressChange((event: OnProgressChangeEvent): void => {
          if (event) {
          }
        })
        .layoutWeight(1)
        .width('100%')
    }
    .height('100%')
  }

}