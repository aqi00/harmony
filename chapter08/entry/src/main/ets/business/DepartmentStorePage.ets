import { DepartmentHomeView } from './DepartmentHomeView';
import { DepartmentClassView } from './DepartmentClassView';
import { DepartmentCartView } from './DepartmentCartView';

@Entry
@Component
struct DepartmentStorePage {
  @State normalColor: string = '#182431'; // 正常的颜色
  @State selectedColor: string = '#007DFF'; // 被选中时的颜色
  @State current: number = 0; // 当前页签的序号

  // 自定义单个页签的布局内容。需传入各页签的序号、名称、高亮图标、灰显图标
  @Builder tabBuilder(index: number, name: string, selectedIcon: Resource, normalIcon: Resource) {
    Stack() {
      // 区分当前页和其他页的背景，当前页背景高亮，其他页背景灰显
      Image(this.current === index ? $r('app.media.tab_bg_selected'): $r('app.media.tab_bg_normal'))
        .width('100%').height('100%').objectFit(ImageFit.Fill)
      Column() {
        // 区分当前页和其他页的图标，当前页图标高亮，其他页图标灰显
        Image(this.current === index ? selectedIcon : normalIcon).width(40).height(40)
        Text(name).fontSize(15).lineHeight(22).margin({ top: 0, bottom: 5 })
          // 区分当前页和其他页的文字颜色，当前页字色高亮，其他页字色灰显
          .fontColor(this.current === index ? this.selectedColor : this.normalColor)
            // 区分当前页和其他页的字号样式，当前页字号加粗，其他页字号正常
          .fontWeight(this.current === index ? FontWeight.Bold : FontWeight.Normal)
      }.width('100%').padding(5)
    }.width('100%')
  }

  build() {
    // barPosition取值Start表示放在开头，取值End表示放在末尾
    Tabs({ barPosition: BarPosition.End, index: $$this.current }) {
      TabContent() {
        Column() {
          DepartmentHomeView()
        }.width('100%').height('100%')
      }.tabBar(this.tabBuilder(0, '首页', $r('app.media.tab_first_pressed'), $r('app.media.tab_first_normal')))

      TabContent() {
        Column() {
          DepartmentClassView()
        }.width('100%').height('100%')
      }.tabBar(this.tabBuilder(1, '分类', $r('app.media.tab_second_pressed'), $r('app.media.tab_second_normal')))

      TabContent() {
        Column() {
          DepartmentCartView()
        }.width('100%').height('100%')
      }.tabBar(this.tabBuilder(2, '购物车', $r('app.media.tab_third_pressed'), $r('app.media.tab_third_normal')))

    }
    .vertical(false) // 是否垂直布局。默认为false表示水平布局，为true表示垂直布局
    .width('100%').height('100%').barWidth('100%').barHeight(70)
  }
}