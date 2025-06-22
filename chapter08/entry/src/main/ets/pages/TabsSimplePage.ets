import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct TabsSimplePage {
  promptAction = this.getUIContext().getPromptAction();
  @State current: number = 0; // 当前页签的序号

  build() {
    // barPosition取值Start表示放在开头，取值End表示放在末尾
    Tabs({ barPosition: BarPosition.Start, index: this.current }) {
      TabContent() {
        Column().width('100%').height('100%').backgroundColor(Color.Green)
      }.tabBar('绿色')

      TabContent() {
        Column().width('100%').height('100%').backgroundColor(Color.Blue)
      }.tabBar({icon: $r('app.media.startIcon'), text: '蓝色'})

      TabContent() {
        Column().width('100%').height('100%').backgroundColor(Color.Yellow)
      }.tabBar(SubTabBarStyle.of('黄色'))

      TabContent() {
        Column().width('100%').height('100%').backgroundColor(Color.Pink)
      }.tabBar(BottomTabBarStyle.of($r('app.media.startIcon'), '粉色'))
    }
    .vertical(false) // 是否垂直布局。默认为false表示水平布局，为true表示垂直布局
    .barMode(BarMode.Fixed) // 页签栏模式。默认Fixed表示固定，为Scrollable表示允许滑动
    .barWidth('100%') // 页签栏的宽度
    .barHeight(60) // 页签栏的高度
    .animationDuration(400) // 页签切换动画的时长
    .onChange((index: number) => {
      this.current = index
      this.promptAction.showToast({message: '切换到第' + index + '个页签'})
    })
    .width('100%').height('100%')
  }
}