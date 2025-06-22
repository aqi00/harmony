import { ItemOption } from '../entity/ItemOption';

@Entry
@Component
struct GridRegularPage {
  private planetArray: ItemOption[] = [
    { name: '水星', icon: $r('app.media.shuixing'), desc: '水星是太阳系八大行星最内侧也是最小的一颗行星，也是离太阳最近的行星' },
    { name: '金星', icon: $r('app.media.jinxing'), desc: '金星是太阳系八大行星之一，排行第二，距离太阳0.725天文单位' },
    { name: '地球', icon: $r('app.media.diqiu'), desc: '地球是太阳系八大行星之一，排行第三，也是太阳系中直径、质量和密度最大的类地行星，距离太阳1.5亿公里' },
    { name: '火星', icon: $r('app.media.huoxing'), desc: '火星是太阳系八大行星之一，排行第四，属于类地行星，直径约为地球的53%' },
    { name: '木星', icon: $r('app.media.muxing'), desc: '木星是太阳系八大行星中体积最大、自转最快的行星，排行第五。它的质量为太阳的千分之一，但为太阳系中其它七大行星质量总和的2.5倍' },
    { name: '土星', icon: $r('app.media.tuxing'), desc: '土星为太阳系八大行星之一，排行第六，体积仅次于木星' }];

  build() {
    Grid() {
      ForEach(this.planetArray, (item: ItemOption) => {
        GridItem() {
          Column() {
            Text(item.name).fontSize(25)
            Image(item.icon).width(80)
            Text(item.desc).fontSize(17)
              // textOverflow需配合maxLines使用，若无textOverflow，文字就全部显示
              .maxLines(4).textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .padding(5).backgroundColor(Color.White)
      })
    }
    .columnsTemplate('1fr 1fr')  // 将Grid容器分为等宽的两列
    .columnsGap(5) // 列与列的间距
    .rowsGap(5) // 行与行的间距
    .backgroundColor(Color.Red)
  }
}