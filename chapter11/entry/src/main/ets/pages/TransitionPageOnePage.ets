import { router } from '@kit.ArkUI';

@Entry
@Component
struct TransitionPageOnePage {
  router = this.getUIContext().getRouter();
  @State scaleRatio: number = 1; // 缩放比例
  @State alphaValue: number = 1; // 不透明度

  build() {
    Stack() {
      Image($r('app.media.fade_begin')).width('100%').height('100%')
      Button('打开下一页').width('100%').fontSize(18)
        .onClick(() => {
          this.router.pushUrl({ url: 'pages/TransitionPageTwoPage' })
        })
    }
    .width('100%').height('100%')
    .scale({ x: this.scaleRatio }) // 缩放比例
    .opacity(this.alphaValue) // 不透明度
  }

  pageTransition() {
    // 下面采用系统自带的页面转场动画。PageTransitionEnter为转入动画，PageTransitionExit为转出动画
    PageTransitionEnter({ duration: 2000 }).slide(SlideEffect.Left)
    PageTransitionExit({ duration: 2000 }) // 持续时间为两秒
      .translate({ x: 100.0, y: 100.0 }) // 平移距离
      .opacity(0) // 不透明度
    // // 下面通过重写onEnter和onExit实现自定义的页面转场动画
    // PageTransitionEnter({ duration: 1200, curve: Curve.Linear })
    //   .onEnter((type: RouteType, progress: number) => {
    //     if (type == RouteType.Push||type == RouteType.Pop) {
    //       this.scaleRatio = progress
    //       this.alphaValue = progress
    //     }
    //   })
    // PageTransitionExit({ duration: 1200, curve: Curve.Ease })
    //   .onExit((type: RouteType, progress: number) => {
    //     if (type == RouteType.Push) {
    //       this.scaleRatio = 1 - progress
    //       this.alphaValue = 1 - progress
    //     }
    //   })
  }
}