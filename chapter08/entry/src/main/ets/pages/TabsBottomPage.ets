@Entry
@Component
struct TabsBottomPage {
  @State current: number = 0; // 当前页签的序号

  // 自定义单个页签的布局内容。需传入各页签的序号、名称、高亮图标、灰显图标
  @Builder tabBuilder(index: number, name: string, selectedIcon: Resource, normalIcon: Resource) {
    Stack() {
      // 区分当前页和其他页的背景，当前页背景高亮，其他页背景灰显
      Image(this.current == index ? $r('app.media.tab_bg_selected') : $r('app.media.tab_bg_normal'))
        .width('100%').height('100%').objectFit(ImageFit.Fill)
      Column() {
        // 区分当前页和其他页的图标，当前页图标高亮，其他页图标灰显
        Image(this.current == index ? selectedIcon : normalIcon).width(40).height(40)
        Text(name).fontSize(15).lineHeight(22).margin({ top: 0, bottom: 5 })
          // 区分当前页和其他页的文字颜色，当前页字色高亮，其他页字色灰显
          .fontColor(this.current == index ? Color.Blue : Color.Gray)
          // 区分当前页和其他页的字号样式，当前页字号加粗，其他页字号正常
          .fontWeight(this.current == index ? FontWeight.Bold : FontWeight.Normal)
      }.width('100%').padding(5)
    }.width('100%')
  }

  build() {
    // barPosition取值Start表示放在开头，取值End表示放在末尾
    Tabs({ barPosition: BarPosition.End, index: $$this.current }) {
      TabContent() {
        Column() {
          Text('这里是首页页面').fontSize(30).margin({bottom: 50})
        }.width('100%').height('100%').justifyContent(FlexAlign.End)
      }.tabBar(this.tabBuilder(0, '首页', $r('app.media.tab_first_pressed'), $r('app.media.tab_first_normal')))
      TabContent() {
        Column() {
          Text('这里是分类页面').fontSize(30).margin({bottom: 50})
        }.width('100%').height('100%').justifyContent(FlexAlign.End)
      }.tabBar(this.tabBuilder(1, '分类', $r('app.media.tab_second_pressed'), $r('app.media.tab_second_normal')))
      TabContent() {
        Column() {
          Text('这里是我的页面').fontSize(30).margin({bottom: 50})
        }.width('100%').height('100%').justifyContent(FlexAlign.End)
      }.tabBar(this.tabBuilder(2, '我的', $r('app.media.tab_third_pressed'), $r('app.media.tab_third_normal')))
    }
    .vertical(false) // 是否垂直布局。默认为false表示水平布局，为true表示垂直布局
    .barMode(BarMode.Fixed) // 页签栏模式。默认Fixed表示固定，为Scrollable表示允许滑动
    .barWidth('100%') // 页签栏的宽度
    .barHeight(70) // 页签栏的高度
    .animationDuration(0) // 页签切换动画的时长
    .width('100%').height('100%')
  }
}