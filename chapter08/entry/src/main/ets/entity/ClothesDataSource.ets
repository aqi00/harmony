import { GoodsInfo } from '../entity/GoodsInfo';


// 实现IDataSource接口的对象，用于瀑布流组件加载数据
export class ClothesDataSource implements IDataSource {
  private dataArray: GoodsInfo[] = GoodsInfo.getDefaultClot();

  // 必须实现的5个方法：constructor、totalCount、getData、registerDataChangeListener、unregisterDataChangeListener
  constructor() {}

  // 获取数据总数
  totalCount(): number {
    return this.dataArray.length
  }

  // 获取索引对应的数据
  getData(index: number): GoodsInfo {
    return this.dataArray[index]
  }

  // 注册改变数据的控制器
  registerDataChangeListener(listener: DataChangeListener): void {}

  // 注销改变数据的控制器
  unregisterDataChangeListener() {}
}