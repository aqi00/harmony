import { common } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'
import { systemDateTime } from '@kit.BasicServicesKit'
import { util } from '@kit.ArkTS'
import { webview } from '@kit.ArkWeb'

import { BridgeHandler } from './BridgeHandler'
import { BridgeUtil } from './BridgeUtil'
import { CallBackFunction } from './CallBackFunction'
import { DefaultHandler } from './DefaultHandler'
import { Message } from './Message'
import { WebViewJavascriptBridge } from './WebViewJavascriptBridge'

export class BridgeController implements WebViewJavascriptBridge {
  // 内部持有原生控制器
  private controller: webview.WebviewController = new webview.WebviewController()

  private responseCallbacks = new Map<String, CallBackFunction>();
  private messageHandlers = new Map<String, BridgeHandler>();
  private defaultHandler: BridgeHandler = new DefaultHandler();
  private uniqueId: number = 0;
  private startupMessage: Message[] = [];

  public getStartupMessage(): Message[] {
    return this.startupMessage;
  }

  public setStartupMessage(startupMessage: Message[]): void {
    this.startupMessage = startupMessage;
  }

  public setDefaultHandler(handler: BridgeHandler): void {
    this.defaultHandler = handler;
  }

  public handlerReturnData(url: string): void {
    let functionName: string = BridgeUtil.getFunctionFromReturnUrl(url);
    let f: CallBackFunction|undefined = this.responseCallbacks.get(functionName);
    let data: string = BridgeUtil.getDataFromReturnUrl(url);
    if (f != undefined && f != null) {
      f.onCallBack(data);
      this.responseCallbacks.delete(functionName);
      return;
    }
  }

  send(data: string): void {
    this.sendWithCallback(data, undefined);
  }

  sendWithCallback(data: string, responseCallback?: CallBackFunction): void {
    this.doSend('', data, responseCallback);
  }

  private doSend(handlerName: string, data: string, responseCallback?: CallBackFunction): void {
    let msg: Message = new Message('', '', '', '', '');
    if (data!=null) {
      msg.data = data
    }
    if (responseCallback != null) {
      let callbackStr: string = util.format(BridgeUtil.CALLBACK_ID_FORMAT,
        ++this.uniqueId + (BridgeUtil.UNDERLINE_STR + systemDateTime.getTime()));
      this.responseCallbacks.set(callbackStr, responseCallback);
      msg.callbackId = callbackStr
    }
    if (handlerName!=undefined && handlerName!=null && handlerName!='') {
      msg.handlerName = handlerName
    }
    this.queueMessage(msg);
  }

  private queueMessage(msg: Message): void {
    if (this.startupMessage != null) {
      this.startupMessage.push(msg);
    } else {
      this.dispatchMessage(msg);
    }
  }

  public dispatchMessage(msg: Message): void {
    let  messageJson: string = msg.toJson();
    //escape special characters for json string
    messageJson = messageJson.replaceAll("(\\\\)([^utrn])", "\\\\\\\\$1$2");
    messageJson = messageJson.replaceAll("(?<=[^\\\\])(\")", "\\\\\"");
    messageJson = messageJson.replaceAll("\n", "");
    let javascriptCommand: string = util.format(BridgeUtil.JS_HANDLE_MESSAGE_FROM_JAVA, messageJson);
    this.controller.runJavaScriptExt(javascriptCommand).catch((err: BusinessError) => {
      console.error('runJavaScriptExt failed with err: ' + JSON.stringify(err));
    });

  }

  public flushMessageQueue(): void {
    console.info('begin flushMessageQueue')
    let callbackBig: CallBackFunction = {
      onCallBack: (data: string): void => {
        console.info(`回调数据: ${data}`)
        let list: Message[] = [];
        try {
          list = Message.toArrayList(data);
        } catch (err) {
          console.error(`Message.toArrayList failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        if (list == null || list.length == 0) {
          return;
        }
        for (let msg of list) {
          let responseId: string = msg.responseId;
          // 是否是response
          if (responseId != null && responseId != '') {
            let callback: CallBackFunction | undefined = this.responseCallbacks.get(responseId);
            let responseData: string = msg.responseData;
            callback?.onCallBack(responseData);
            this.responseCallbacks.delete(responseId);
          } else {
            let responseFunction: CallBackFunction | undefined = undefined;
            // if had callbackId
            let callbackId: string = msg.callbackId;
            if (callbackId != null && callbackId != '') {
              responseFunction = {
                onCallBack: (data: string): void => {
                  let responseMsg: Message = new Message('', '', '', '', '');
                  responseMsg.responseId = callbackId;
                  responseMsg.responseData = data;
                  this.queueMessage(responseMsg);
                }
              };
            } else {
              responseFunction = {
                onCallBack: (data: string): void => {
                  // do nothing
                }
              };
            }
            let handler: BridgeHandler | undefined;
            if (msg.handlerName != null && msg.handlerName != '') {
              handler = this.messageHandlers.get(msg.handlerName);
            } else {
              handler = this.defaultHandler;
            }
            if (handler != null) {
              handler?.handler(msg.data, responseFunction);
            }
          }
        }
      }
    }
    this.loadUrlNew(BridgeUtil.JS_FETCH_QUEUE_FROM_JAVA, callbackBig);
  }

  public loadUrlNew(jsUrl: string, returnCallback: CallBackFunction): void {
    this.responseCallbacks.set(BridgeUtil.parseFunctionName(jsUrl), returnCallback);
    this.controller.runJavaScriptExt(jsUrl).catch((err: BusinessError) => {
      console.error('runJavaScriptExt failed with err: ' + JSON.stringify(err));
    });
  }

  /**
   * register handler,so that javascript can call it
   *
   * @param handlerName
   * @param handler
   */
  public registerHandler(handlerName: string, handler: BridgeHandler): void {
    if (handler != null) {
      this.messageHandlers.set(handlerName, handler);
    }
  }

  /**
   * call javascript registered handler
   *
   * @param handlerName
   * @param data
   * @param callBack
   */
  public callHandler(handlerName: string, data: string, callBack: CallBackFunction): void {
    this.doSend(handlerName, data, callBack);
  }

  getNativeController(): webview.WebviewController {
    return this.controller
  }

  setNativeController(controller: webview.WebviewController) {
    this.controller = controller
  }

  /**
   * js 文件将注入为第一个script引用
   *
   * @param view
   * @param url
   */
   public webViewLoadJs(url: string): void {
    let js: string = "var newscript = document.createElement(\"script\");";
    js += "newscript.src=\"" + url + "\";";
    js += "document.scripts[0].parentNode.insertBefore(newscript,document.scripts[0]);";
     this.controller.runJavaScriptExt("javascript:" + js).catch((err: BusinessError) => {
      console.error('runJavaScriptExt failed with err: ' + JSON.stringify(err));
    });
  }

  public webViewLoadLocalJs(context: common.UIAbilityContext, path: string): void {
     let fullPath = util.format('%s/%s', context.resourceDir, path)
     let jsContent: string = fileIo.readTextSync(fullPath)
     this.controller.runJavaScriptExt("javascript:" + jsContent).catch((err: BusinessError) => {
       console.error('runJavaScriptExt failed with err: ' + JSON.stringify(err));
     });
   }

  // // ==================== JavaScript 执行 ====================
  //
  // // 异步执行 JS（回调方式）
  // runJavaScriptExt(script: string, callback: (result: JsResult) => void): void {
  //   this.controller.runJavaScriptExt(script).catch((err: BusinessError) => {
  //     console.error('runJavaScriptExt failed with err: ' + JSON.stringify(err));
  //   });
  // }
  //
  // // 异步执行 JS（Promise 方式）
  // runJavaScriptAsync(script: string): Promise<JsResult> {
  //   return new Promise<JsResult>((resolve: (value: JsResult) => void): void => {
  //     this.runJavaScriptExt(script, (result: JsResult): void => {
  //       resolve(result)
  //     })
  //   })
  // }
  //
  // // 批量执行 JS 脚本（按顺序串行执行）
  // runJavaScriptBatch(scripts: string[]): Promise<JsResult[]> {
  //   return new Promise<JsResult[]>((resolve: (value: JsResult[]) => void): void => {
  //     let results: JsResult[] = []
  //     let index: number = 0
  //
  //     let executeNext: () => void = (): void => {
  //       if (index >= scripts.length) {
  //         resolve(results)
  //         return
  //       }
  //       this.runJavaScriptExt(scripts[index], (result: JsResult): void => {
  //         results.push(result)
  //         index++
  //         executeNext()
  //       })
  //     }
  //     executeNext()
  //   })
  // }

}