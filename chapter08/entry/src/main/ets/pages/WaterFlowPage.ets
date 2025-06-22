import { WaterFlowDataSource } from '../entity/WaterFlowDataSource'
import { ItemOption } from '../entity/ItemOption'

@Entry
@Component
struct WaterFlowPage {
  private dataSource: WaterFlowDataSource = new WaterFlowDataSource(); // 瀑布流的数据源

  build() {
    // WaterFlow必须使用懒加载，从dataSource中根据各项高度动态调整位置
    WaterFlow() {
      LazyForEach(this.dataSource, (item: ItemOption) => {
        FlowItem() {
          Column() {
            Text(item.name).fontSize(25)
            Image(item.icon).width(80)
            Text(item.desc).width('100%').fontSize(16)
          }
        }
        .width('100%').padding(5).backgroundColor(Color.White)
      })
    }
    .columnsTemplate('1fr 1fr') // 将WaterFlow容器分为等宽的两列
    .columnsGap(5) // 列与列的间距
    .rowsGap(5) // 行与行的间距
    .backgroundColor(Color.Green)
  }
}