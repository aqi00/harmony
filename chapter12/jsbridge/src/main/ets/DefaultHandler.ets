import { BridgeHandler } from './BridgeHandler';
import { CallBackFunction } from './CallBackFunction';

export class DefaultHandler implements BridgeHandler {
  TAG: string = 'DefaultHandler';

  handler(data: string, callback: CallBackFunction): void {
    if (callback != null) {
      callback.onCallBack('DefaultHandler response data');
    }
  }
}
