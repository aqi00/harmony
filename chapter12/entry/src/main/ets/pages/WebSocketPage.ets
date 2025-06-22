import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../constant/Constants';

let ws = webSocket.createWebSocket(); // WebSocket的客户端对象

@Entry
@Component
struct WebSocketPage {
  @State content: string = ''; // 传输内容
  @State result: string = '未连接服务器'; // 通信结果

  aboutToAppear() {
    ws.on('open', (err: BusinessError, value: Object) => {
      if (err) {
        console.error('open fail, err: ' + JSON.stringify(err));
        return
      }
      this.result = '已连上服务器'
    });
    // 建立WebSocket连接
    ws.connect(Constants.WEBSOCKET_PREFIX, (err: BusinessError, value: boolean) => {
      if (err) {
        console.error('connect fail, err: ' + JSON.stringify(err));
        return
      }
      console.info('connect success');
      // 开始监听消息事件
      ws.on('message', (error: BusinessError, value: string | ArrayBuffer) => {
        console.info('on message, message:' + value);
        this.result = '服务端返回：' + value as string
        // 当收到服务器的`bye`消息时（此消息字段仅为示意，具体字段需要与服务器协商），主动断开连接
        if (value === 'bye') {
          ws.close((err: BusinessError, value: boolean) => {
            if (!err) {
              console.info('close success');
            } else {
              console.error('close fail, err is ' + JSON.stringify(err));
            }
          });
        }
      });
    })
  }

  aboutToDisappear() {
    ws.off('message') // 取消监听消息事件
    ws.close() // 关闭WebSocket连接
  }

  build() {
    Column() {
      Row() {
        TextInput({ text: $$this.content, placeholder: '请输入消息' })
          .layoutWeight(1).height(40).fontSize(18).type(InputType.Normal)
      }.margin(5)
      Button('发送WebSocket消息').width('100%').fontSize(18)
        .onClick(() => {
          // 当收到on('open')事件时，可以通过send()方法与服务器进行通信
          ws.send(this.content) // 发送文本消息
          // ws.send(this.content, (err: BusinessError, value: boolean) => {
          //   if (!err) {
          //     console.info('send success');
          //   } else {
          //     console.error('send fail, err:' + JSON.stringify(err));
          //   }
          // });
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%')
  }
}