export class SwipeDataSource implements IDataSource {
  private dataArray: Array<Resource> = [
    $r("app.media.banner_1"),
    $r("app.media.banner_2"),
    $r("app.media.banner_3"),
    $r("app.media.banner_4"),
    $r("app.media.banner_5"), ];

  // 必须实现的5个方法：constructor、totalCount、getData、registerDataChangeListener、unregisterDataChangeListener
  constructor() {}

  // 获取数据总数
  totalCount(): number {
    return this.dataArray.length
  }

  // 获取索引对应的数据
  getData(index: number): Resource {
    return this.dataArray[index]
  }

  // 注册改变数据的控制器
  registerDataChangeListener(listener: DataChangeListener): void {}

  // 注销改变数据的控制器
  unregisterDataChangeListener() {}
}