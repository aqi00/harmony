class MessageInfo {
  callbackId: string
  responseId: string
  responseData: string
  data: string
  handlerName: string

  constructor(callbackId: string, responseId: string, responseData: string, data: string, handlerName: string) {
    this.callbackId = callbackId
    this.responseId = responseId
    this.responseData = responseData
    this.data = data
    this.handlerName = handlerName
  }
}

export class Message {
  callbackId: string
  responseId: string
  responseData: string
  data: string
  handlerName: string

  static CALLBACK_ID_STR: string = 'callbackId';
  static RESPONSE_ID_STR: string = 'responseId';
  static RESPONSE_DATA_STR: string = 'responseData';
  static DATA_STR: string = 'data';
  static HANDLER_NAME_STR: string = 'handlerName';

  constructor(callbackId: string, responseId: string, responseData: string, data: string, handlerName: string) {
    this.callbackId = callbackId
    this.responseId = responseId
    this.responseData = responseData
    this.data = data
    this.handlerName = handlerName
  }

  toJson(): string {
    let message = new MessageInfo(this.callbackId, this.responseId, this.responseData, this.data, this.handlerName)
    return JSON.stringify(message)
  }

  static toObject(jsonStr: string): Message {
    let msg = JSON.parse(jsonStr) as Message
    return msg
  }

  static toArrayList(jsonStr: string): Message[]{
    let list = JSON.parse(jsonStr) as Message[]
    return list
  }
}
