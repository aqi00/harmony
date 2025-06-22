
export class GoodsInfo {
  public pic: string; // 商品图片
  public name: string; // 商品名称
  public desc: string; // 商品描述

  public constructor(pic: string, name: string, desc: string) {
    this.pic = pic;
    this.name = name;
    this.desc = desc;
  }

  private static gridImageArray: string[] = ['app.media.pic_01', 'app.media.pic_02', 'app.media.pic_03',
    'app.media.pic_04', 'app.media.pic_05', 'app.media.pic_06', 'app.media.pic_07',
    'app.media.pic_08', 'app.media.pic_09', 'app.media.pic_10'];
  private static gridNameArray: string[] = ['商场', '超市', '百货', '便利店',
    '地摊', '食杂店', '饭店', '餐厅', '会所', '菜市场'];

  public static getDefaultGrid(): Array<GoodsInfo> {
    let gridArray = new Array<GoodsInfo>();
    for (let i = 0; i < GoodsInfo.gridImageArray.length; i++) {
      gridArray.push(new GoodsInfo(GoodsInfo.gridImageArray[i], GoodsInfo.gridNameArray[i], ''));
    }
    return gridArray;
  }

  private static stagImageArray: string[] = ['app.media.skirt01', 'app.media.skirt02', 'app.media.skirt03',
    'app.media.skirt04', 'app.media.skirt05', 'app.media.skirt06', 'app.media.skirt07',
    'app.media.skirt08', 'app.media.skirt09', 'app.media.skirt10', 'app.media.skirt11',
    'app.media.skirt12', 'app.media.skirt13', 'app.media.skirt14', 'app.media.skirt15',
    'app.media.skirt16', 'app.media.skirt17', 'app.media.skirt18', 'app.media.skirt19',
    'app.media.skirt20', 'app.media.skirt21', 'app.media.skirt22', 'app.media.skirt23'];
  private static stagNameArray: string[] = ['促销价', '惊爆价', '跳楼价', '白菜价', '清仓价', '割肉价',
    '实惠价', '一口价', '满意价', '打折价', '腰斩价', '真实惠', '算了吧', '大声点',
    '嘘嘘', '嗯嗯', '呼呼', '呵呵', '哈哈', '嘿嘿', '嘻嘻', '嗷嗷', '喔喔'];

  public static getDefaultClot(): Array<GoodsInfo> {
    let stagArray = new Array<GoodsInfo>();
    for (let i = 0; i < GoodsInfo.stagImageArray.length; i++) {
      stagArray.push(new GoodsInfo(GoodsInfo.stagImageArray[i], GoodsInfo.stagNameArray[i], ''));
    }
    return stagArray;
  }

  private static combineImageArray: string[] = ['app.media.cainixihuan', 'app.media.dapaijiadao',
    'app.media.trip_01', 'app.media.trip_02', 'app.media.trip_03', 'app.media.trip_04'];
  private static combineNameArray: string[] = [
    '猜你喜欢', '大牌驾到', '买哪个', '别想了', '先下单', '包你满意'];

  public static getDefaultCombine(): Array<GoodsInfo> {
    let combineArray = new Array<GoodsInfo>();
    for (let i = 0; i < GoodsInfo.combineImageArray.length; i++) {
      combineArray.push(new GoodsInfo(GoodsInfo.combineImageArray[i], GoodsInfo.combineNameArray[i], ''));
    }
    return combineArray;
  }

  private static appiImageArray: string[] = ['app.media.dian01', 'app.media.dian02', 'app.media.dian03',
      'app.media.dian04', 'app.media.dian05', 'app.media.dian06', 'app.media.dian07',
      'app.media.dian08', 'app.media.dian09', 'app.media.dian10', 'app.media.dian11',
      'app.media.dian12', 'app.media.dian13', 'app.media.dian14', 'app.media.dian15'];
  private static appiNameArray: string[] = ['双十一', '大聚惠', '爆款价',
    '就一次', '手慢无', '快点击', '付定金', '享特权', '包安装', '再返券',
    '白送你', '想得美', '干活去', '好好学', '才有钱'];

  public static getDefaultAppi(): Array<GoodsInfo> {
    let appiArray = new Array<GoodsInfo>();
    for (let i = 0; i < GoodsInfo.appiImageArray.length; i++) {
      appiArray.push(new GoodsInfo(GoodsInfo.appiImageArray[i], GoodsInfo.appiNameArray[i], ''));
    }
    return appiArray;
  }

  // 声明一个手机商品的大图数组
  private static phonePicArray = [
    'app.media.iphone', 'app.media.huawei', 'app.media.xiaomi',
    'app.media.oppo', 'app.media.vivo', 'app.media.rongyao'
  ]
  // 声明一个手机商品的名称数组
  private static phoneNameArray = [
    'iPhone11', 'Mate30', '小米10', 'OPPO Reno3', 'vivo X30', '荣耀30S'
  ]
  // 声明一个手机商品的描述数组
  private static phoneDescArray = [
    'Apple iPhone11 256GB 绿色 4G全网通手机',
    '华为 HUAWEI Mate30 8GB+256GB 丹霞橙 5G全网通 全面屏手机',
    '小米 MI10 8GB+128GB 钛银黑 5G手机 游戏拍照手机',
    'OPPO Reno3 8GB+128GB 蓝色星夜 双模5G 拍照游戏智能手机',
    'vivo X30 8GB+128GB 绯云 5G全网通 美颜拍照手机',
    '荣耀30S 8GB+128GB 蝶羽红 5G芯片 自拍全面屏手机'
  ]

  public static getDefaultPhone(): GoodsInfo[] {
    let goodsArray: GoodsInfo[] = []
    for (let i=0; i<GoodsInfo.phoneNameArray.length; i++) {
      goodsArray.push(new GoodsInfo(GoodsInfo.phonePicArray[i], GoodsInfo.phoneNameArray[i], GoodsInfo.phoneDescArray[i]))
    }
    return goodsArray
  }

}