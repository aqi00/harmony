import { promptAction } from '@kit.ArkUI';
import { SwipeDataSource } from '../entity/SwipeDataSource';

@Entry
@Component
struct SwiperVerticalPage {
  promptAction = this.getUIContext().getPromptAction();
  private bannerArray: Array<Resource> = [ $r("app.media.banner_1"),
    $r("app.media.banner_2"), $r("app.media.banner_3"),
    $r("app.media.banner_4"), $r("app.media.banner_5") ];
  // private swiperController: SwiperController = new SwiperController(); // 滑块控制器
  // private dataSource: SwipeDataSource = new SwipeDataSource(); // 滑块的数据来源

  build() {
    Swiper() {
      ForEach(this.bannerArray, (item: Resource) => {
        Image(item).width('100%').height(150).objectFit(ImageFit.Cover)
      })
    }
    .vertical(true) // 是否垂直方向。默认为false表示水平方向，为true表示垂直方向
    .indicator(true) // 是否显示指示器。垂直翻页时，指示器在右侧中央
    .onChange((index: number) => { // index从0开始计数
      this.promptAction.showToast({message: '滑动到第' + index + '个组件'})
    })
    // Column() {
    //   Swiper() {
    //     ForEach(this.bannerArray, (item: Resource) => {
    //       Image(item).width('100%').height(150).objectFit(ImageFit.Cover)
    //     })
    //   }
    //   Swiper(this.swiperController) {
    //     LazyForEach(this.dataSource, (item: Resource) => {
    //       Image(item)
    //         .width('100%').height(150).objectFit(ImageFit.Cover)
    //     }, (item: string) => item)
    //   }
    //   .vertical(true) // 是否垂直方向。默认为false表示水平方向，为true表示垂直方向
    //   .indicator(true) // 是否显示指示器。垂直翻页时，指示器在右侧中央
    //   .index(0) // 默认显示第几个组件
    //   .onChange((index: number) => { // index从0开始计数
    //     this.promptAction.showToast({message: '滑动到第' + index + '个组件'})
    //   })
    //
    //   Row({ space: 12 }) {
    //     Button('上一个').fontSize(18)
    //       .onClick(() => {
    //         this.swiperController.showPrevious() // 显示上页
    //       })
    //     Button('下一个').fontSize(18)
    //       .onClick(() => {
    //         this.swiperController.showNext() // 显示下页
    //       })
    //   }.margin(5)
    // }.width('100%')
  }
}