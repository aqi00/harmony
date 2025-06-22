import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SwiperDigitPage {
  promptAction = this.getUIContext().getPromptAction();
  private bannerArray: Array<Resource> = [ $r("app.media.banner_1"),
    $r("app.media.banner_2"), $r("app.media.banner_3"),
    $r("app.media.banner_4"), $r("app.media.banner_5") ];

  build() {
    Swiper() {
      ForEach(this.bannerArray, (item: Resource) => {
        Image(item).width('100%').height(150).objectFit(ImageFit.Cover)
      })
    }
    .vertical(false) // 是否垂直方向。默认为false表示水平方向，为true表示垂直方向
    .index(0) // 默认显示第几个组件
    .autoPlay(true) // 是否自动轮播
    .loop(true) // 是否循环轮播
    .interval(4000) // 轮播间隔，单位毫秒
    .duration(1000) // 轮播时长，单位毫秒
    .displayArrow(true, false) // 设置导航点箭头样式
    .indicator( // 设置数字导航点样式
      new DigitIndicator()
        .fontColor(Color.White) // 数字导航点的文字颜色
        .digitFont({ size: 25 }) // 数字导航点的字体样式
        .selectedFontColor(Color.Black) // 当前项数字的文字颜色
        .selectedDigitFont({ size: 25, weight: FontWeight.Bold }))
    .onChange((index: number) => {
      this.promptAction.showToast({message: '轮播到第' + index + '个组件'})
    })
  }
}