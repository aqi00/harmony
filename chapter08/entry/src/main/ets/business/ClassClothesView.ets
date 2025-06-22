import { GoodsInfo } from '../entity/GoodsInfo';
import { ClothesDataSource } from '../entity/ClothesDataSource';

@Component
export struct ClassClothesView {
  private dataSource: ClothesDataSource = new ClothesDataSource(); // 服装瀑布流的数据源

  build() {
    WaterFlow() {
      // WaterFlow必须使用懒加载，从dataSource中根据各项高度动态调整位置
      LazyForEach(this.dataSource, (item: GoodsInfo) => {
        FlowItem() {
          Column() {
            Image($r(item.pic)).width('100%').objectFit(ImageFit.Contain)
            Text(item.name).fontSize(18)
          }
        }
        .width('100%').padding(0).backgroundColor(Color.White)
      }, (item: string) => item)
    }
    .columnsTemplate('1fr 1fr 1fr') // 将WaterFlow容器分为等宽的三列
    .columnsGap(2).rowsGap(2).padding(2).backgroundColor(Color.Yellow)
  }
}
