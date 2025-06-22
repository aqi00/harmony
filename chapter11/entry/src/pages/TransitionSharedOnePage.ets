import { router } from '@kit.ArkUI';

@Entry
@Component
struct TransitionSharedOnePage {

  build() {
    Stack() {
      Image($r('app.media.fade_begin')).width('100%').height('100%')
      Column() {
        Row() {
          Image($r('app.media.startIcon'))
            .width(120).height(80).objectFit(ImageFit.Contain)
            // 共享组件的编号ID要相同
            .sharedTransition('sharedImage', { duration: 2000 })
          Button('打开下一页').height('100%').fontSize(25)
            .onClick(() => {
              this.router.pushUrl({ url: 'pages/TransitionSharedTwoPage' })
            })
        }.height(80)
      }
      .width('100%').height('100%')
    }
    .width('100%').height('100%')
  }

  pageTransition() {
    // 下面采用系统自带的页面转场动画。PageTransitionEnter为转入动画，PageTransitionExit为转出动画
    PageTransitionEnter({ duration: 2000 }).slide(SlideEffect.Left)
    PageTransitionExit({ duration: 2000 }) // 持续时间为两秒
      .translate({ x: 100.0, y: 100.0 }) // 缩放比例
      .opacity(0) // 不透明度
  }
}