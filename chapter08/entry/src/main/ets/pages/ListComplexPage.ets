import { ItemOption } from '../entity/ItemOption';

@Entry
@Component
struct ListComplexPage {
  private planetArray: ItemOption[] = [
    { name: '水星', icon: $r('app.media.shuixing'), desc: '水星是太阳系八大行星最内侧也是最小的一颗行星，也是离太阳最近的行星' },
    { name: '金星', icon: $r('app.media.jinxing'), desc: '金星是太阳系八大行星之一，排行第二，距离太阳0.725天文单位' },
    { name: '地球', icon: $r('app.media.diqiu'), desc: '地球是太阳系八大行星之一，排行第三，也是太阳系中直径、质量和密度最大的类地行星，距离太阳1.5亿公里' },
    { name: '火星', icon: $r('app.media.huoxing'), desc: '火星是太阳系八大行星之一，排行第四，属于类地行星，直径约为地球的53%' },
    { name: '木星', icon: $r('app.media.muxing'), desc: '木星是太阳系八大行星中体积最大、自转最快的行星，排行第五。它的质量为太阳的千分之一，但为太阳系中其它七大行星质量总和的2.5倍' },
    { name: '土星', icon: $r('app.media.tuxing'), desc: '土星为太阳系八大行星之一，排行第六，体积仅次于木星' }];

  build() {
    List({ space: 5, initialIndex: 0 }) {
      ForEach(this.planetArray, (item: ItemOption) => {
        ListItem() {
          Row() {
            Image(item.icon).width(90).height('100%')
            Column() {
              Text(item.name).width('100%').fontSize(25)
              Text(item.desc).width('100%').layoutWeight(1).fontSize(17)
                // textOverflow需配合maxLines使用，若无textOverflow，文字就全部显示
                .maxLines(3).textOverflow({overflow: TextOverflow.Ellipsis})
                .textAlign(TextAlign.Start) // 水平方向朝左对齐
                .align(Alignment.Top) // 垂直方向朝上对齐
            }.layoutWeight(1).padding({left:5})
          }.height('100%')
        }.height(90) // 内部组件可能超出这个高度限制
      })
    }
    .listDirection(Axis.Vertical) // 列表排列方向。默认Vertical表示垂直，为Horizontal表示水平
    .scrollBar(BarState.Off) // 滚动条状态。默认BarState.Auto
    .divider({ strokeWidth: 2, color: Color.Gray, startMargin: 10, endMargin: 10 }) // 每行之间的分界线
    .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
    .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
      console.info(`onScroll scrollState = ScrollState` + scrollState + `, scrollOffset = ` + scrollOffset)
    })
    .width('100%').padding(5)
  }
}