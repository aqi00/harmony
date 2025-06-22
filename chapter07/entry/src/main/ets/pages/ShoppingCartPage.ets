import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';

import { CartInfo } from '../entity/CartInfo';
import { GoodsInfo } from '../entity/GoodsInfo';
import { TitleView } from '../view/TitleView';
import { CartDB } from '../entity/CartDB';
import { GoodsDB } from '../entity/GoodsDB';

@Entry
@Component
struct ShoppingCartPage {
  context = this.getUIContext().getHostContext();
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State title: string = '购物车'; // 频道标题
  @State count: number = 0; // 已加入购物车的商品数量
  @State totalPrice: number = 0; // 商品总价
  @State cartArray: CartInfo[] = []; // 购物车里的商品清单

  private dataPref?: preferences.Preferences; // 首选项实例
  private cart_db: CartDB = new CartDB(); // 购物车信息的数据库实例
  private goods_db: GoodsDB = new GoodsDB(); // 商品信息的数据库实例
  aboutToAppear() {
    let options: preferences.Options = { name: 'cart_store' };
    this.dataPref = preferences.getPreferencesSync(this.context, options);
    this.cart_db = new CartDB()
    this.goods_db = new GoodsDB()
    console.info('aboutToAppear')
  }

  onPageShow() {
    console.info('onPageShow')
    setTimeout(() => {
      this.downloadGoods()
      let count = 0
      let totalPrice = 0
      let cartArray = this.cart_db.queryAll()
      for (let i=0; i<cartArray.length; i++) {
        count += cartArray[i].count
        cartArray[i].goods_info = this.goods_db.queryGoodsById(cartArray[i].goodsId)
        totalPrice += cartArray[i].count * cartArray[i].goods_info.price
        console.info('picPath='+cartArray[i].goods_info.picPath)
      }
      this.count = count
      this.totalPrice = totalPrice
      this.cartArray = cartArray.slice()
    }, 200)
  }

  build() {
    Column() {
      TitleView({title:$title, count:$count})
      Scroll() {
        Stack() {
          if (this.count > 0) {
            Column() {
              Row() {
                Text('图片').width(85).fontSize(15).textAlign(TextAlign.Center)
                Text('名称').layoutWeight(3).fontSize(15).textAlign(TextAlign.Center)
                Text('数量').layoutWeight(1).fontSize(15).textAlign(TextAlign.Center)
                Text('单价').layoutWeight(1).fontSize(15).textAlign(TextAlign.Center)
                Text('总价').layoutWeight(1.2).fontSize(15).textAlign(TextAlign.Center)
              }.width('100%').height(20)
              ForEach(this.cartArray, (item: CartInfo) => {
                Row() {
                  Image($r(item.goods_info.picPath)).width(85).height(85).objectFit(ImageFit.Contain)
                  Column() {
                    Text(item.goods_info.name).width('100%').layoutWeight(2)
                      .fontSize(17).textAlign(TextAlign.Start)
                    Text(item.goods_info.desc).width('100%').layoutWeight(3)
                      .fontSize(12).textAlign(TextAlign.Start)
                  }.layoutWeight(3)
                  Text(''+item.count).layoutWeight(1).fontSize(17).textAlign(TextAlign.Center)
                  Text(''+item.goods_info.price).layoutWeight(1).fontSize(15).textAlign(TextAlign.End)
                  Text(''+(item.count*item.goods_info.price)).layoutWeight(1.2)
                    .fontSize(17).fontColor(Color.Red).textAlign(TextAlign.End)
                }
                .width('100%').height(85).backgroundColor(Color.White)
                .onClick(() => {
                  // pushUrl默认采用Standard标准模式跳转，为Single表示单实例跳转
                  this.router.pushUrl({
                    url: 'pages/ShoppingDetailPage',
                    params: {
                      goods_id: item.goodsId,
                    }
                  })
                })
                .gesture(
                  // fingers为触发长按的最少手指数。默认为1指
                  // repeat表示是否连续触发事件回调。默认false
                  LongPressGesture({ fingers: 1, repeat: false })
                    .onAction((event: GestureEvent) => {
                      if (event) {
                        this.promptAction.showDialog({
                          message: `是否从购物车删除${item.goods_info.name}？`,
                          buttons: [
                            { text: '是', color: '#000000' },
                            { text: '否', color: '#000000' },
                          ]
                        }).then(data => {
                          if (data.index == 0) {
                            this.deleteGoods(item)
                          }
                        })
                      }
                    })
                )
              })
              Blank().layoutWeight(1)
              Row() {
                Button('清空').fontSize(18)
                  .onClick(() => {
                    this.count = 0
                    this.cartArray.length = 0
                    this.cart_db.deleteAll()
                    this.promptAction.showToast({ message: '购物车已清空' })
                  })
                Text('总金额：').layoutWeight(1).fontSize(17).textAlign(TextAlign.End)
                Text(''+this.totalPrice).fontSize(25).fontColor(Color.Red).margin({right:10})
                Button('结算').fontSize(18)
                  .onClick(() => {
                    this.promptAction.showDialog({
                      title: '结算商品',
                      message: '客官抱歉，支付功能尚未开通，请下次再来',
                      buttons: [
                        { text: '我知道了', color: '#000000' }
                      ]
                    })
                  })
              }.width('100%').height(55).padding(10)
            }
          } else {
            Column() {
              Text('哎呀，购物车空空如也，快去选购商品吧')
                .fontSize(18).margin({top:100, bottom:100})
              Button('逛逛手机商场').width('100%').fontSize(17)
                .onClick(() => {
                  this.router.pushUrl({ url: 'pages/ShoppingChannelPage' })
                })
              Blank().layoutWeight(1)
            }
          }
        }.width('100%').height('100%').backgroundColor('#ffffdd')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%').height('100%')
  }

  deleteGoods(cart_info: CartInfo) {
    this.count -= cart_info.count
    for (let i=0; i<this.cartArray.length; i++) {
      if (this.cartArray[i].id == cart_info.id) {
        this.cartArray.splice(i, 1)
        break
      }
    }
    this.cart_db.delete(cart_info.id)
    this.promptAction.showToast({ message: '已从购物车删除'+cart_info.goods_info.name })
  }

  downloadGoods() {
    console.info('downloadGoods 1')
    let isFirst = this.dataPref?.getSync('first', 'true')
    console.info('isFirst='+isFirst)
    if (isFirst == 'true') { // 首次加载商品信息
      console.info('downloadGoods 2')
      let goodsArray = GoodsInfo.getDefaultList()
      for (let item of goodsArray) {
        this.goods_db.insert(item)
        console.info('insert:'+item.name)
      }
    }
    this.dataPref?.putSync('first', 'false')
    this.dataPref?.flush() // 持久化缓存中的首选项数据
  }
}