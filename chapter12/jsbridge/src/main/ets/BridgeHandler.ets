import { CallBackFunction } from './CallBackFunction';

export interface BridgeHandler {

  handler: (data: string, callback: CallBackFunction) => void

}
