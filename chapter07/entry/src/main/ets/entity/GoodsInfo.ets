export class GoodsInfo {
  id: number
  name: string
  desc: string
  price: number
  picPath: string

  constructor() {
    this.id = -1
    this.name = ''
    this.desc = ''
    this.price = 0
    this.picPath = ''
  }

  // 声明一个手机商品的名称数组
  private static mNameArray = [
    'iPhone11', 'Mate30', '小米10', 'OPPO Reno3', 'vivo X30', '荣耀30S'
  ]
  // 声明一个手机商品的描述数组
  private static mDescArray = [
    'Apple iPhone11 256GB 绿色 4G全网通手机',
    '华为 HUAWEI Mate30 8GB+256GB 丹霞橙 5G全网通 全面屏手机',
    '小米 MI10 8GB+128GB 钛银黑 5G手机 游戏拍照手机',
    'OPPO Reno3 8GB+128GB 蓝色星夜 双模5G 拍照游戏智能手机',
    'vivo X30 8GB+128GB 绯云 5G全网通 美颜拍照手机',
    '荣耀30S 8GB+128GB 蝶羽红 5G芯片 自拍全面屏手机'
  ]
  // 声明一个手机商品的价格数组
  private static mPriceArray = [6299, 4999, 3999, 2999, 2998, 2399]
  // 声明一个手机商品的大图数组
  private static mPicArray = [
    'app.media.iphone', 'app.media.huawei', 'app.media.xiaomi',
    'app.media.oppo', 'app.media.vivo', 'app.media.rongyao'
  ]

  public static getDefaultList(): GoodsInfo[] {
    let goodsList: GoodsInfo[] = []
    for (let i=0; i<GoodsInfo.mNameArray.length; i++) {
      let info = new GoodsInfo()
      info.name = GoodsInfo.mNameArray[i];
      info.desc = GoodsInfo.mDescArray[i];
      info.price = GoodsInfo.mPriceArray[i];
      info.picPath = GoodsInfo.mPicArray[i];
      goodsList.push(info)
    }
    return goodsList
  }

}