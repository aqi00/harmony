import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { client_socket } from '@ohos/socketio';
import { GlobalThis } from './GlobalThis';
import { Constants } from '../constant/Constants'

import { emitter } from '@kit.BasicServicesKit';

@Entry
@Component
struct WeLoginPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State nickName: string = ''; // 昵称
  private client?: client_socket; // SocketIO客户端

  aboutToAppear() {
    this.client = GlobalThis.getInstance().getSocket()
    this.client?.set_open_listener(() => {
      console.info('set_open_listener')
    })
    this.client?.set_fail_listener(() => {
      console.info('set_fail_listener')
    })
    this.client?.set_close_listener(() => {
      console.info('set_close_listener')
    })
    this.client?.set_reconnecting_listener(() => {
      console.info('set_reconnecting_listener')
    });
    this.client?.set_reconnect_listener(() => {
      console.info('set_reconnect_listener')
    });
    this.client?.set_socket_open_listener((nsp: string) => {
      console.info('set_socket_open_listener: '+nsp)
      if (this.nickName!='') {
        this.client?.emit('self_online', this.nickName) // 发送上线通知
        let eventData: emitter.EventData = {
          data: {
            'socket_status': 'open'
          }
        }
        setTimeout(() => {
          emitter.emit('socket_status', eventData)
        }, 200)
      }
    });
    this.client?.set_socket_close_listener((nsp: string) => {
      console.info('set_socket_close_listener: '+nsp)
      let eventData: emitter.EventData = {
        data: {
          'socket_status': 'close'
        }
      }
      emitter.emit('socket_status', eventData)
    });
    this.client?.connect(Constants.SOCKET_CHAT_URL) // socket.io服务端地址
    this.client?.opened()
  }

  aboutToDisappear() {
    this.client?.close();
    //this.client.socket_close(); // 注意：这里不可调用socket_close，否则app会崩溃
    this.client?.clear_socket_listeners();
  }

  build() {
    Column() {
      Blank().height('5%')
      Image($r('app.media.wechat'))
        .width(150).height(150).objectFit(ImageFit.Contain)
      Text('请输入您的昵称').fontSize(18).margin(15)
      TextInput({text: $$this.nickName, placeholder: '请输入昵称'})
        .width('100%').height(40)
        .type(InputType.Normal).fontSize(18).maxLength(12)
      Button('登　录')
        .width('100%').fontSize(18).margin({ top: 10 })
        .onClick(() => {
          if (this.nickName.length == 0) {
            this.promptAction.showToast({message: '请输入您的微信昵称'})
            return
          }
          this.router.pushUrl({
            url: 'chat/WeChatPage',
            params: {
              nickName: this.nickName,
            }
          })
        })
    }
    .width('100%').height('100%')
  }
}