import { router } from '@kit.ArkUI';

@Entry
@Component
struct TransitionSharedTwoPage {

  build() {
    Stack() {
      Image($r('app.media.fade_end')).width('100%').height('100%')
      Image($r('app.media.startIcon'))
        .width(200).height(200).objectFit(ImageFit.Contain)
        // 共享组件的编号ID要相同
        .sharedTransition('sharedImage', { duration: 2000 })
    }
    .width('100%').height('100%')
    .onClick(() => {
      this.router.back() // 返回上一页
      //this.router.pushUrl({ url: 'pages/TransitionSharedOnePage' })
    })
  }

  pageTransition() {
    // 下面采用系统自带的页面转场动画。PageTransitionEnter为转入动画，PageTransitionExit为转出动画
    PageTransitionEnter({ duration: 2000 }).slide(SlideEffect.Left)
    PageTransitionExit({ duration: 2000 }) // 持续时间为两秒
      .translate({ x: 100.0, y: 100.0 }) // 缩放比例
      .opacity(0) // 不透明度
  }
}