import { router } from '@kit.ArkUI';

@Component
export struct TitleView {
  router = this.getUIContext().getRouter();
  @Link title: string; // 标题
  @Link count: number; // 商品数量

  build() {
    RelativeContainer() {
      Text(this.title).fontSize(20)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      Image($r('app.media.cart'))
        .width(50).height(50).objectFit(ImageFit.Contain)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .onClick(() => {
          this.router.pushUrl({ url: 'pages/ShoppingCartPage' }, router.RouterMode.Single)
        })
      Circle().width(20).height(20).fill(Color.Red)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
      Text(''+this.count).width(20).height(20).textAlign(TextAlign.Center)
        .fontSize(15).fontColor(Color.White)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
    }
    .width('100%').height(50).backgroundColor(0xaaaaff)
  }
}