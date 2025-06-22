import { client_socket } from '@ohos/socketio';
import { Constants } from '../constant/Constants';

@Entry
@Component
struct SocketioTextPage {
  @State content: string = '小兔子乖乖，把门儿开开。'; // 待发送的文本消息
  @State result: string = '结果在这里'; // 消息收发结果
  private client: client_socket = new client_socket(); // socketio的客户端对象

  aboutToAppear() {
    this.client.set_open_listener(() => {
      console.info('set_open_listener')
      this.result = '已连上服务器'
    })
    this.client.set_fail_listener(() => {
      console.info('set_fail_listener')
      this.result = '连接服务器失败'
    })
    this.client.set_close_listener(() => {
      console.info('set_close_listener')
    })
    this.client.set_reconnecting_listener(() => {
      console.info('set_reconnecting_listener')
    });
    this.client.set_reconnect_listener(() => {
      console.info('set_reconnect_listener')
      this.result = '尝试连接服务器……'
    });
    this.client.set_socket_open_listener((nsp: string) => {
      console.info('set_socket_open_listener: '+nsp)
    });
    this.client.set_socket_close_listener((nsp: string) => {
      console.info('set_socket_open_listener: '+nsp)
    });
    this.client.connect(Constants.SOCKET_SIMPLE_URL) // socket.io服务端地址
    // 注意：未改动的socketio只认new message，这里用的socketio是改动了的
    this.client.on('receive_text', (text: string) => {
      console.info('receive_message: '+text)
      this.result = '收到服务端返回文本消息：'+text
    })
  }

  aboutToDisappear() {
    this.client.off('receive_text') // 取消接收文本消息的监听
    this.client.close();
    //this.client.socket_close(); // 注意：这里不可调用socket_close，否则app会崩溃
    this.client.clear_socket_listeners();
  }

  build() {
    Column() {
      Row() {
        TextInput({ text: $$this.content, placeholder: '请输入消息' })
          .layoutWeight(1).height(40).fontSize(18).type(InputType.Normal)
      }.margin(5)
      Button('发送文本消息').width('100%').fontSize(18)
        .onClick(() => {
          console.info('begin send: '+this.content)
          this.client.emit('send_text', this.content);
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%')
  }
}