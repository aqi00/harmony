import { ChatUtil } from '../utils/ChatUtil';
import { CustomInputDialog } from '../view/CustomInputDialog'
import { client_socket } from '@ohos/socketio';
import { GlobalThis } from './GlobalThis';

@Component
export struct MyInfoView {
  @State TAG: string = 'MyInfoView';
  @Consume @Watch('onDataChanged') nickName: string; // 昵称
  private client?: client_socket; // SocketIO客户端
  @State portrait: Resource|undefined = undefined; // 我的头像
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomInputDialog({
      cancel: (): void => this.cancel(),
      confirm: (nickName: string): void => this.confirm(nickName)
    }),
    customStyle: false, // 是否自定义样式
    alignment: DialogAlignment.Center // 对话框的对齐方式
  });

  // 取消对话框
  cancel() {
    console.info('CustomInputDialog:cancel()')
  }

  // 确认对话框
  confirm(nickName: string) {
    console.info('CustomInputDialog:confirm()')
    this.nickName = nickName
    ChatUtil.getPortraitByName(this.nickName, (result: Resource) => {
      this.portrait = result
    })
    this.client?.emit('self_offline', nickName);
    this.client?.emit('self_online', this.nickName);
  }

  onDataChanged() {
    console.info(this.TAG, 'onDataChanged')
    ChatUtil.getPortraitByName(this.nickName, (result: Resource) => {
      this.portrait = result
    })
  }

  aboutToAppear() {
    console.info(this.TAG, 'aboutToAppear');
    this.client = GlobalThis.getInstance().getSocket()
    ChatUtil.getPortraitByName(this.nickName, (result: Resource) => {
      this.portrait = result
    })
  }

  build() {
    Column() {
      Text('个人信息').fontSize(20)
      Row() {
        Text('头像：').height('100%').fontSize(18).padding(10).align(Alignment.Center)
        Image(this.portrait).height('100%').objectFit(ImageFit.Contain)
      }.width('100%').height(100)
      Row() {
        Text('昵称：').height('100%').fontSize(18).padding(10).align(Alignment.Center)
        Text(this.nickName).height('100%').fontSize(18).align(Alignment.Center)
          .onClick(() => {
            this.dialogController.open() // 打开对话框
          })
      }.width('100%').height(100)
    }
    .width('100%').height('100%').padding(5)
  }
}