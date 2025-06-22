import { router } from '@kit.ArkUI';
import { ChatUtil } from '../utils/ChatUtil';
import { client_socket } from '@ohos/socketio';
import { GlobalThis } from './GlobalThis';

@Component
export struct FriendListView {
  router = this.getUIContext().getRouter();
  @State TAG: string = 'FriendListView';
  @Consume @Watch('onDataChanged') nickName: string; // 昵称
  private client?: client_socket; // SocketIO客户端
  private friendMap = new Map<string, string>(); // 好友映射
  @State friendArray: SelectOption[] = []; // 好友列表
  @State title: string = `好友（0）`; // 好友标题

  onDataChanged() {
    console.info(this.TAG, 'onDataChanged')
  }

  aboutToAppear() {
    console.info(this.TAG, 'aboutToAppear');
    console.info(this.TAG, 'nickName='+this.nickName)
    this.client = GlobalThis.getInstance().getSocket()
    this.client?.on('friend_online', (friend_name: string) => {
      console.info('friend_online: '+friend_name)
      if (friend_name.length > 0) {
        this.friendMap.set(friend_name, friend_name)
        this.refreshList() // 刷新好友列表
      }
    })
    this.client?.on('friend_offline', (friend_name: string) => {
      console.info('friend_offline: '+friend_name)
      if (friend_name.length > 0) {
        this.friendMap.delete(friend_name)
        this.refreshList() // 刷新好友列表
      }
    })
    this.client?.emit('self_online', this.nickName) // 发送上线通知
  }

  aboutToDisappear() {
    this.client?.emit('self_offline', this.nickName) // 发送下线通知
    this.client?.off('friend_online') // 取消监听好友上线事件
    this.client?.off('friend_offline') // 取消监听好友下线事件
  }

  // 刷新好友列表
  refreshList() {
    this.friendArray.length = 0
    let iterator = this.friendMap.keys()
    let result = iterator.next()
    while (!result.done) {
      let friendName = result.value
      ChatUtil.getPortraitByName(friendName, (result: Resource) => {
        let friend: SelectOption = { value: friendName, icon: result }
        this.friendArray.push(friend)
        this.title = `好友（${this.friendArray.length}）`
        console.info(this.TAG, `friendMap.size=${this.friendMap.size}, friendArray.length=${this.friendArray.length}, title=${this.title}`)
      })
      result = iterator.next()
    }
  }

  build() {
    Column() {
      Text(this.title).fontSize(20)
      List({ space: 5, initialIndex: 0 }) {
        ForEach(this.friendArray, (item: SelectOption) => {
          ListItem() {
            Row() {
              Image(item.icon).width(60).objectFit(ImageFit.Contain)
              Blank().width(15)
              Text(item.value).width('100%').height(30).fontSize(18)//.textAlign(TextAlign.Start)
            }
            .onClick(() => {
              this.router.pushUrl({
                url: 'chat/FriendChatPage',
                params: {
                  nickName: this.nickName,
                  friendName: item.value,
                }
              })
            })
          }
        })
      }
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .divider({ strokeWidth: 0.5, color: 0xcccccc, startMargin: 50, endMargin: 0 })
      .edgeEffect(EdgeEffect.Fade)
      .width('100%').layoutWeight(1).padding(5)
    }
    .width('100%').height('100%').padding(5)
  }
}