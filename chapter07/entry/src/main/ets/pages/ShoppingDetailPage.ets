import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

import { GoodsInfo } from '../entity/GoodsInfo';
import { TitleView } from '../view/TitleView';
import { CartDB } from '../entity/CartDB';
import { GoodsDB } from '../entity/GoodsDB';

@Entry
@Component
struct ShoppingDetailPage {
  context = this.getUIContext().getHostContext();
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State title: string = ''; // 频道标题
  @State count: number = 0; // 已加入购物车的商品数量
  @State goods_info: GoodsInfo = new GoodsInfo(); // 当前页的商品信息

  private cart_db: CartDB = new CartDB(); // 购物车信息的数据库实例
  private goods_db: GoodsDB = new GoodsDB(); // 商品信息的数据库实例
  aboutToAppear() {
    this.cart_db = new CartDB()
    this.goods_db = new GoodsDB()
  }

  onPageShow() {
    setTimeout(() => {
      let count = 0
      let cartArray = this.cart_db.queryAll() // 查询购物车
      for (let i=0; i<cartArray.length; i++) {
        count += cartArray[i].count
      }
      this.count = count
      let params = this.router.getParams() as Record<string, Object>;
      let goods_id = params?.['goods_id'] as number
      this.goods_info = this.goods_db.queryGoodsById(goods_id)
      this.title = this.goods_info.name
    }, 200)
  }

  build() {
    Column() {
      TitleView({title:$title, count:this.count})
      Scroll() {
        Column() {
          Image($r(this.goods_info.picPath))
            .width('100%').height(350).objectFit(ImageFit.Contain)
          Text(''+this.goods_info.price)
            .width('100%').fontSize(22).fontColor(Color.Red).padding({left:5})
          Text(this.goods_info.desc)
            .width('100%').fontSize(15).fontColor(Color.Black).padding({left:5})
          Button('加入购物车').width('100%').fontSize(18)
            .onClick(() => {
              this.count++
              this.cart_db.save(this.goods_info.id)
              this.promptAction.showToast({ message: '成功添加至购物车' })
            })
        }.width('100%').height('100%').backgroundColor('#ffffdd')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%').height('100%')
  }
}