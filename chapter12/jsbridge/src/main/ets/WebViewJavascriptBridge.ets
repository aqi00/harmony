import { CallBackFunction } from './CallBackFunction'

export interface WebViewJavascriptBridge {

  send(data: string): void

  sendWithCallback(data: string, responseCallback?: CallBackFunction): void

}
