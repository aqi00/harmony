import { router } from '@kit.ArkUI';

@Component
export struct GroupListView {
  router = this.getUIContext().getRouter();
  @State TAG: string = 'GroupListView';
  @Consume @Watch('onDataChanged') nickName: string; // 昵称
  private groupArray: SelectOption[] = [
    { value: '鸿蒙开发技术交流群', icon: $r('app.media.portrait01') },
    { value: '摄影爱好者', icon: $r('app.media.portrait07') },
    { value: '人工智能学习讨论群', icon: $r('app.media.portrait13') }];
  @State title: string = `群聊（${this.groupArray.length}）`; // 群聊标题

  onDataChanged() {
    console.info(this.TAG, 'onDataChanged')
  }

  aboutToAppear() {
    console.info(this.TAG, 'aboutToAppear');
  }

  build() {
    Column() {
      Text(this.title).fontSize(20)
      List({ space: 5, initialIndex: 0 }) {
        ForEach(this.groupArray, (item: SelectOption) => {
          ListItem() {
            Row() {
              Image(item.icon).width(60).objectFit(ImageFit.Contain)
              Blank().width(15)
              Text(item.value).width('100%').height(30).fontSize(18)//.textAlign(TextAlign.Start)
            }
            .onClick(() => {
              this.router.pushUrl({
                url: 'chat/GroupChatPage',
                params: {
                  nickName: this.nickName,
                  groupName: item.value,
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