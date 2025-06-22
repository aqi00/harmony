import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { ChatUtil } from '../utils/ChatUtil';
import { client_socket } from '@ohos/socketio';
import { GlobalThis } from './GlobalThis';
import { ChatInfo } from '../entity/ChatInfo';
import { MessageInfo } from '../entity/MessageInfo';
import { JoinInfo } from '../entity/JoinInfo';
import { Utils } from '../utils/Utils';
import { ChatItemView } from '../view/ChatItemView';

import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { buffer } from '@kit.ArkTS';
import { util } from '@kit.ArkTS';
import { ImagePart } from '../entity/ImagePart';
import { ImageMessage } from '../entity/ImageMessage';

import { emitter } from '@kit.BasicServicesKit';

@Entry
@Component
struct GroupChatPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State TAG: string = 'GroupChatPage';
  private client?: client_socket; // SocketIO客户端
  @State nickName: string = ''; // 昵称
  @State groupName: string = ''; // 群名称
  @State myPortrait: Resource|undefined = undefined; // 我的头像
  @State title: string = ''; // 群聊标题
  private personCount: number = 0; // 群人数
  private minute: string = '00:00'; // 群消息时分

  @State content: string = ''; // 群消息文本
  @State chatMsgArray: Array<ChatInfo> = []; // 群消息列表
  private scroller: Scroller = new Scroller(); // 滚动器

  // 滚动到底部
  scrollToBottom() {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom, {velocity: 250})
    }, 200)
  }

  // 添加提示消息
  appendHintMsg(hint: string) {
    this.appendNowMinute() // 添加消息接收时间
    let chatInfo: ChatInfo = { type: 0, source: 0, content: hint}
    this.chatMsgArray.push(chatInfo)
    this.scrollToBottom() // 滚动到最后一条聊天消息
  }

  // 添加聊天消息
  appendChatMsg(type: number, source: number, name: string, portrait: Resource, content: string) {
    this.appendNowMinute() // 添加消息接收时间
    let chatInfo: ChatInfo = { type: type, source: source, name: name, portrait: portrait, content: content}
    chatInfo.isGroup = true
    this.chatMsgArray.push(chatInfo)
    this.scrollToBottom() // 滚动到最后一条聊天消息
  }

  // 添加聊天图片
  appendChatPic(type: number, source: number, name: string, portrait: Resource, pixelMap: PixelMap) {
    this.appendNowMinute() // 添加消息接收时间
    let chatInfo: ChatInfo = { type: type, source: source, name: name, portrait: portrait, pixelMap: pixelMap}
    chatInfo.isGroup = true
    let size = pixelMap.getImageInfoSync().size
    chatInfo.aspect = size.width/size.height
    this.chatMsgArray.push(chatInfo)
    this.scrollToBottom() // 滚动到最后一条聊天消息
  }

  // 添加当前时间
  appendNowMinute() {
    let nowMinute = Utils.getNowMinute()
    if (this.minute != nowMinute) {
      this.minute = nowMinute
      let chatInfo: ChatInfo = { type: 0, source: 0, content: this.minute}
      this.chatMsgArray.push(chatInfo)
      this.scrollToBottom() // 滚动到最后一条聊天消息
    }
  }

  aboutToAppear() {
    console.info(this.TAG, 'aboutToAppear');
    let params = this.router.getParams() as Record<string, Object>;
    this.nickName = params?.['nickName'] as string
    this.groupName = params?.['groupName'] as string
    console.info(this.TAG, `nickName:${this.nickName}, groupName:${this.groupName}`);
    this.title = this.groupName
    ChatUtil.getPortraitByName(this.nickName, (result: Resource) => {
      this.myPortrait = result
    })
    this.client = GlobalThis.getInstance().getSocket()
    this.client.on('person_count', (count: string) => {
      console.info('person_count: '+count)
      if (!isNaN(Number(count))) {
        this.personCount = Number(count)
        this.title = `${this.groupName}（${this.personCount}）`
      }
    })
    this.client.on('person_in_group', (person_name: string) => {
      console.info('person_in_group: '+person_name)
      if (this.nickName != person_name) {
        this.personCount++
        this.title = `${this.groupName}（${this.personCount}）`
      }
      this.appendHintMsg(`${person_name} 加入了群聊`)
    })
    this.client.on('person_out_group', (person_name: string) => {
      console.info('person_out_group: '+person_name)
      if (this.nickName != person_name) {
        this.personCount--
        this.title = `${this.groupName}（${this.personCount}）`
        this.appendHintMsg(`${person_name} 退出了群聊`)
      }
    })
    this.client.on('receive_group_message', (data: string) => {
      console.info('receive_group_message: '+data)
      let msgInfo = JSON.parse(data) as MessageInfo
      ChatUtil.getPortraitByName(msgInfo.from, (result: Resource) => {
        this.appendChatMsg(1, 2, msgInfo.from, result, msgInfo.content)
      })
    })
    this.client.on('receive_group_image', (data: string) => {
      console.info('receive_group_image: '+data)
      this.receiveImage(data) // 接收群图片
    })
    let joinInfo: JoinInfo = { user_name: this.nickName, group_name: this.groupName }
    let msg = JSON.stringify(joinInfo)
    console.info('join_group: '+msg)
    this.client.emit('join_group', msg) // 发送入群通知
    // this.client.on('heart_beat', (data: string) => {
    //   console.info('heart_beat: '+data)
    // })
    emitter.on('socket_status', (event) => {
      if (event != undefined && event.data != undefined) {
        let socket_status = event.data.socket_status as string
        console.info(this.TAG, 'socket_status='+socket_status)
        if (socket_status == 'open') {
          this.client?.emit('join_group', msg) // 发送入群通知
        }
      }
    })
  }

  aboutToDisappear() {
    let joinInfo: JoinInfo = { user_name: this.nickName, group_name: this.groupName }
    let msg = JSON.stringify(joinInfo)
    console.info('leave_group: '+msg)
    this.client?.emit('leave_group', msg) // 发送退群通知
    this.client?.off('person_count') // 取消接收群人数通知
    this.client?.off('person_in_group') // 取消接收成员入群通知
    this.client?.off('person_out_group') // 取消接收成员退群通知
    this.client?.off('receive_group_message') // 取消接收群消息
    this.client?.off('receive_group_image') // 取消接收群图片
    this.client?.off('heart_beat') // 取消接收心跳消息
    emitter.off('socket_status')
  }

  // 发送聊天消息
  sendMessage() {
    this.appendChatMsg(1, 1, this.nickName, this.myPortrait!, this.content)
    let messageInfo: MessageInfo = { from: this.nickName, to: this.groupName, content: this.content }
    let msg = JSON.stringify(messageInfo) // 文本消息转为JSON字符串
    console.info('send_group_message: '+msg)
    this.client?.emit('send_group_message', msg)
    this.content = ''
  }

  build() {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.icon_back')).width(25).height('100%')
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              this.router.back() // 返回到前一个页面
            })
          Text(this.title).height('100%').margin({left: 10})
            .fontSize(19).align(Alignment.Center)
        }.width('100%').height(45).padding({left: 10})
        Divider().strokeWidth(0.5).color(0xdddddd)
      }.expandSafeArea([SafeAreaType.KEYBOARD]) // 注意Ability还要设置压缩模式
      List({ space: 5, initialIndex: 0, scroller: this.scroller }) {
        ForEach(this.chatMsgArray, (item: ChatInfo) => {
          if (item.source == 0) {
            ListItem() {
              Row() {
                Text(item.content).fontSize(14).fontColor(Color.Gray)
              }.width('100%').margin({ top: 10 }).justifyContent(FlexAlign.Center)
            }
          } else {
            ListItem() {
              ChatItemView({info: item})
            }
          }
        })
      }
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .width('100%').layoutWeight(1).padding(5)
      Row() {
        TextArea({text: $$this.content, placeholder: '请输入聊天内容'})
          .height('100%').layoutWeight(1).fontSize(16).align(Alignment.Center)
        Image($r('app.media.add_img')).width(50).height('100%').objectFit(ImageFit.Contain)
          .onClick(() => {
            this.choosePhoto() // 选择相册图片
          })
      }.width('100%').height(50).padding(5)
      Button('发　送').width('100%').fontSize(18)
        .onClick(() => {
          if (this.content.length == 0) {
            this.promptAction.showToast({message: '请输入聊天消息'})
            return
          }
          this.sendMessage() // 发送聊天消息
        })
    }
    .width('100%').height('100%')
    .padding({ left:5, right:5, bottom:5 }).backgroundColor(0xf6f6f6)
  }

  // 选择相册图片
  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      let imagePath = photoSelectResult.photoUris[0]
      this.sendImage(imagePath) // 发送图片

      // 使用fileIo.openSync接口，通过uri打开这个文件得到fd
      let file = fileIo.openSync(imagePath, fileIo.OpenMode.READ_ONLY);
      console.info('MS_LITE_LOG: file fd: ' + file.fd);
      let imageSource = image.createImageSource(file.fd);
      imageSource.createPixelMap().then((pixelMap) => {
        // 添加图片消息
        this.appendChatPic(2, 1, this.nickName, this.myPortrait!, pixelMap)
      }).catch((err: BusinessError) => {
        console.error('createPixelMap failed with err: ' + JSON.stringify(err));
      });
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  // 50*1024时，socketio发送异常
  private blockSize = 45*1024; // 每段的数据包大小
  private lastFile = ''; // 上次的文件名
  private receiveCount = 0; // 接收包的数量
  @State pixelMap: PixelMap | null = null;
  private resultUint8: Uint8Array | null = null; // 整体结果的字节数组

  // 接收图片
  receiveImage(data: string) {
    let msg = JSON.parse(data) as ImageMessage
    let part = msg.part
    if (part.name != this.lastFile) { // 与上次文件名不同，表示开始接收新文件
      this.lastFile = part.name;
      this.receiveCount = 0;
      this.resultUint8 = new Uint8Array(part.length)
    }
    console.info('receive_pic, seq: '+part.seq+', length: '+part.length+', block: '+part.seq*this.blockSize)
    this.receiveCount++;
    // 把接收到的图片数据通过BASE64解码为字节数组
    let helper = new util.Base64Helper();
    let temp = helper.decodeSync(part.data, util.Type.MIME).buffer as ArrayBuffer;
    this.resultUint8?.set(new Uint8Array(temp), part.seq*this.blockSize)
    // 所有数据包都接收完毕
    if (this.receiveCount >= Math.floor(part.length/this.blockSize)+1) {
      this.receiveCount = 0;
      let totalBuffer = this.resultUint8?.buffer as ArrayBuffer
      // 从字节数组中解码得到像素图对象
      let imageSource = image.createImageSource(totalBuffer);
      let opts: image.DecodingOptions = { editable: true };
      imageSource.createPixelMap(opts).then((pixelMap) => {
        this.pixelMap = pixelMap
        console.info('pixelMap size: '+pixelMap.getPixelBytesNumber())
        ChatUtil.getPortraitByName(msg.from, (result: Resource) => {
          // 添加图片消息
          this.appendChatPic(2, 2, msg.from, result, this.pixelMap!)
        })
      }).catch((err: BusinessError) => {
        console.error('createPixelMap error message: ' + err.message + ', error code: ' + err.code);
      })
    }
  }

  // 发送图片
  sendImage(imagePath: string) {
    let fileName = imagePath.toString().split('/').pop() as string
    let suffix = (fileName.split('.').pop() as string).toLowerCase()
    let fileFormat = suffix=='png' ? 'image/png' : 'image/jpeg'
    let file = fileIo.openSync(imagePath, fileIo.OpenMode.READ_ONLY);
    console.info(`fileName: ${fileName}, format:${fileFormat}, fileFd: ${file.fd}`);
    let imageSource = image.createImageSource(file.fd);
    imageSource.createPixelMap().then((pixelMap) => {
      // 转换成base64
      let imagePackerApi: image.ImagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: fileFormat, quality: 100 };
      imagePackerApi.packToData(pixelMap, packOpts).then((data: ArrayBuffer) => {
        let buf: buffer.Buffer = buffer.from(data);
        let count = Math.floor(buf.length/this.blockSize) + 1;
        console.info(`sendImage length=${buf.length}, count=${count}`);
        // 下面把图片数据经过BASE64编码后发给SocketIO服务器
        for (let i=0; i<count; i++) {
          console.info('sendImage i='+i);
          let encodeData = '';
          if (i == count-1) { // 是最后一段图像数据
            let remain = buf.length % this.blockSize;
            let temp = buffer.alloc(remain);
            buf.copy(temp, 0, i*this.blockSize, i*this.blockSize+remain)
            encodeData = temp.toString('base64');
          } else { // 不是最后一段图像数据
            let temp = buffer.alloc(this.blockSize);
            buf.copy(temp, 0, i*this.blockSize, (i+1)*this.blockSize)
            encodeData = temp.toString('base64');
          }
          // 往SocketIO服务器发送本段的图片数据
          let part: ImagePart = {seq:i, name:fileName, data:encodeData, length:buf.length}
          let msg: ImageMessage = {from:this.nickName, to:this.groupName, part:part}
          let data = JSON.stringify(msg) // 图片消息转为JSON字符串
          console.info('i='+i+', size='+encodeData.length+', '+data);
          // 怀疑是socketio限制了数据大小，限制了MAX_BUF_SIZE大小
          this.client?.emit('send_group_image', data); // 发送图像数据
        }
      }).catch((err: BusinessError) => {
        console.error('packing failed with err: ' + JSON.stringify(err));
      });
    }).catch((err: BusinessError) => {
      console.error('createPixelMap failed with err: ' + JSON.stringify(err));
    });
  }

}