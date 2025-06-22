import { ClassClothesView } from '../business/ClassClothesView';
import { ClassAppliancesView } from '../business/ClassAppliancesView';

@Component
export struct DepartmentClassView {
  @State current: number = 0; // 当前页签的序号

  build() {
    // barPosition取值Start表示放在开头，取值End表示放在末尾
    Tabs({ barPosition: BarPosition.Start, index: $$this.current }) {
      TabContent() {
        ClassClothesView()
      }.tabBar(SubTabBarStyle.of('服装'))
      TabContent() {
        ClassAppliancesView()
      }.tabBar(SubTabBarStyle.of('电器'))
    }
    .vertical(false) // 是否垂直布局。默认为false表示水平布局，为true表示垂直布局
    .width('100%').height('100%').barWidth('100%').barHeight(60)
  }
}
