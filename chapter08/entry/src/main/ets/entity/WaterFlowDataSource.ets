import { ItemOption } from './ItemOption';

// 实现IDataSource接口的对象，用于瀑布流组件加载数据
export class WaterFlowDataSource implements IDataSource {
  private planetArray: ItemOption[] = [
    { name: '水星', icon: $r("app.media.shuixing"), desc: '水星是太阳系八大行星最内侧也是最小的一颗行星，也是离太阳最近的行星' },
    { name: '金星', icon: $r("app.media.jinxing"), desc: '金星是太阳系八大行星之一，排行第二，距离太阳0.725天文单位' },
    { name: '地球', icon: $r("app.media.diqiu"), desc: '地球是太阳系八大行星之一，排行第三，也是太阳系中直径、质量和密度最大的类地行星，距离太阳1.5亿公里' },
    { name: '火星', icon: $r("app.media.huoxing"), desc: '火星是太阳系八大行星之一，排行第四，属于类地行星，直径约为地球的53%' },
    { name: '木星', icon: $r("app.media.muxing"), desc: '木星是太阳系八大行星中体积最大、自转最快的行星，排行第五。它的质量为太阳的千分之一，但为太阳系中其它七大行星质量总和的2.5倍' },
    { name: '土星', icon: $r("app.media.tuxing"), desc: '土星为太阳系八大行星之一，排行第六，体积仅次于木星' }];

  // 必须实现的5个方法：constructor、totalCount、getData、registerDataChangeListener、unregisterDataChangeListener
  constructor() {}

  // 获取数据总数
  totalCount(): number {
    return this.planetArray.length
  }

  // 获取索引对应的数据
  getData(index: number): ItemOption {
    return this.planetArray[index]
  }

  // 注册改变数据的控制器
  registerDataChangeListener(listener: DataChangeListener): void {}

  // 注销改变数据的控制器
  unregisterDataChangeListener() {}
}