import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SwiperDotPage {
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
    .displayArrow({
      showBackground: true, // 是否显示箭头底板
      isSidebarMiddle: true, // 箭头是否位于两侧中央
      backgroundSize: 24, // 设置底板的大小
      backgroundColor: Color.White, // 设置底板的颜色
      arrowSize: 20, // 设置箭头的大小
      arrowColor: Color.Blue // 设置箭头的颜色
    }, false)
    .indicator( // 设置圆点导航点样式
      new DotIndicator()
        .itemWidth(15) // 圆点导航指示器的宽度
        .itemHeight(15) // 圆点导航指示器的高度
        .color(Color.White) // 圆点导航指示器的颜色
        .selectedItemWidth(15) // 当前页圆点指示器的宽度
        .selectedItemHeight(15) // 当前页圆点指示器的高度
        .selectedColor(Color.Red))
    .onChange((index: number) => {
      this.promptAction.showToast({message: '轮播到第' + index + '个组件'})
    })
  }
}