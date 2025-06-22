import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

import { GoodsInfo } from '../entity/GoodsInfo'
import { TitleView } from '../view/TitleView';
import { CartDB } from '../entity/CartDB';
import { GoodsDB } from '../entity/GoodsDB';

@Entry
@Component
struct ShoppingChannelPage {
  context = this.getUIContext().getHostContext();
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State title: string = '手机商场'; // 频道标题
  @State count: number = 0; // 已加入购物车的商品数量
  @State goodsArray: GoodsInfo[] = []; // 商品信息列表

  private cart_db: CartDB = new CartDB(); // 购物车信息的数据库实例
  private goods_db: GoodsDB = new GoodsDB(); // 商品信息的数据库实例
  aboutToAppear() {
    this.cart_db = new CartDB()
    this.goods_db = new GoodsDB()
  }

  onPageShow() {
    setTimeout(() => {
      let count = 0
      let cartArray = this.cart_db.queryAll()
      for (let i=0; i<cartArray.length; i++) {
        count += cartArray[i].count
      }
      this.count = count
      this.goodsArray = this.goods_db.queryAll()
    }, 200)
  }

  build() {
    Column() {
      TitleView({title:$title, count:this.count})
      Scroll() {
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
          ForEach(this.goodsArray, (item: GoodsInfo) => {
            Column() {
              Text(item.name).fontSize(17)
              Image($r(item.picPath)).width(180).height(150).objectFit(ImageFit.Contain)
                .onClick(() => {
                  // pushUrl默认采用Standard标准模式跳转，为Single表示单实例跳转
                  this.router.pushUrl({
                    url: 'pages/ShoppingDetailPage',
                    params: {
                      goods_id: item.id,
                    }
                  })
                })
              Row() {
                Text(''+item.price).layoutWeight(2)
                  .fontSize(15).fontColor(Color.Red).textAlign(TextAlign.Center)
                Button('加入购物车').layoutWeight(3).fontSize(15)
                  .onClick(() => {
                    this.count++
                    this.cart_db.save(item.id)
                    this.promptAction.showToast({ message: `已添加一部${item.name}到购物车` })
                  })
              }.width('100%').height(45)
            }.width('50%').backgroundColor(Color.White).alignItems(HorizontalAlign.Center)
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