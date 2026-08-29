export class BridgeUtil {
  static YY_OVERRIDE_SCHEMA: string = 'yy://';
  static YY_RETURN_DATA: string =
    BridgeUtil.YY_OVERRIDE_SCHEMA + 'return/'; //格式为   yy://return/{function}/returncontent
  static YY_FETCH_QUEUE: string = BridgeUtil.YY_RETURN_DATA + '_fetchQueue/';
  static EMPTY_STR: string = '';
  static UNDERLINE_STR: string = '_';
  static SPLIT_MARK: string = '/';
  static CALLBACK_ID_FORMAT: string = 'JAVA_CB_%s';
  static JS_HANDLE_MESSAGE_FROM_JAVA: string = 'javascript:WebViewJavascriptBridge._handleMessageFromNative(\'%s\');';
  static JS_FETCH_QUEUE_FROM_JAVA: string = 'javascript:WebViewJavascriptBridge._fetchQueue();';
  static JAVASCRIPT_STR: string = 'javascript:';

  static parseFunctionName(jsUrl: string): string {
    return jsUrl.replace('javascript:WebViewJavascriptBridge.', '').replaceAll(/\(.*\);/g, '');
  }

  static getDataFromReturnUrl(url: string): string {
    if (url.startsWith(BridgeUtil.YY_FETCH_QUEUE)) {
      return url.replace(BridgeUtil.YY_FETCH_QUEUE, BridgeUtil.EMPTY_STR);
    }

    let temp: string = url.replace(BridgeUtil.YY_RETURN_DATA, BridgeUtil.EMPTY_STR);
    let functionAndData: string[] = temp.split(BridgeUtil.SPLIT_MARK);

    let whole: string = ''
    if (functionAndData.length >= 2) {
      for (let str of functionAndData) {
        whole = whole + str
      }
    }
    return whole;
  }

  static getFunctionFromReturnUrl(url: string) {
    let temp: string = url.replace(BridgeUtil.YY_RETURN_DATA, BridgeUtil.EMPTY_STR);
    let functionAndData: string[] = temp.split(BridgeUtil.SPLIT_MARK);
    if (functionAndData.length >= 1) {
      return functionAndData[0];
    }
    return '';
  }

}
