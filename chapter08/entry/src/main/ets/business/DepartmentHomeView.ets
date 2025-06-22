import { GoodsInfo } from '../entity/GoodsInfo';
import { SwipeDataSource } from '../entity/SwipeDataSource';

@Component
export struct DepartmentHomeView {
  private dataSource: SwipeDataSource = new SwipeDataSource(); // 滑块的数据来源
  @State gridArray: GoodsInfo[] = GoodsInfo.getDefaultGrid(); // 普通网格的商品列表
  @State combineArray: GoodsInfo[] = GoodsInfo.getDefaultCombine(); // 合并网格的商品列表
  @State phoneArray: GoodsInfo[] = GoodsInfo.getDefaultPhone(); // 手机网格的商品列表
  private layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    // 索引为0和1的GridItem占用的列数由onGetIrregularSizeByIndex指定
    irregularIndexes: [0, 1],
    onGetIrregularSizeByIndex: (index: number) => {
      if (index == 0 || index == 1) {
        return [1, 2] // 该项占一行两列
      }
      return [1, 1] // 其他网格占据一行一列
    }
  };

  build() {
    Scroll() {
      Column() {
        Text('商城首页').fontSize(20).padding(10)
        Swiper() {
          LazyForEach(this.dataSource, (item: Resource) => {
            Image(item).width('100%').height(150).objectFit(ImageFit.Cover)
          })
        }
        .vertical(false) // 是否垂直方向。默认为false表示水平方向，为true表示垂直方向
        .indicator(true) // 是否显示指示器。水平翻页时，指示器在底部中央
        .autoPlay(true).loop(true).interval(4000).duration(1000)
        Grid() {
          ForEach(this.gridArray, (item: GoodsInfo) => {
            GridItem() {
              Column() {
                Image($r(item.pic)).width('100%')
                Text(item.name).fontSize(18)
              }
            }
            .padding(5).backgroundColor(Color.White)
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr') // 将Grid容器分为等宽的五列
        .columnsGap(0.5).rowsGap(0.5).backgroundColor(Color.Gray)
        Grid(undefined, this.layoutOptions) {
          ForEach(this.combineArray, (item: GoodsInfo) => {
            GridItem() {
              Column() {
                Image($r(item.pic)).width('100%')
                Text(item.name).fontSize(18)
              }
            }
            .padding(5).backgroundColor(Color.White)
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr') // 将Grid容器分为等宽的四列
        .columnsGap(0.5).rowsGap(0.5).backgroundColor(Color.Gray)
        Grid() {
          ForEach(this.phoneArray, (item: GoodsInfo) => {
            GridItem() {
              Column() {
                Image($r(item.pic)).width('100%')
                Text(item.name).fontSize(18)
              }
            }
            .padding(5).backgroundColor(Color.White)
          })
        }
        .columnsTemplate('1fr 1fr 1fr') // 将Grid容器分为等宽的三列
        .columnsGap(0.5).rowsGap(0.5).backgroundColor(Color.Gray)
      }
    }
    .scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off)
  }
}
