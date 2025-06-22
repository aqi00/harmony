@Entry
@Component
struct FadeAnimationPage {
  @State isShowFirst: boolean = true; // 是否显示第一张图片
  @State beginImage: Resource = $r('app.media.fade_begin'); // 开始图片
  @State endImage: Resource = $r('app.media.fade_end'); // 结束图片

  build() {
    Column() {
      // 鸿蒙的淡入淡出动画被称作“组件内隐式共享元素转场 (geometryTransition)”
      Button('播放淡入淡出动画').width('100%').fontSize(18)
        .onClick(() => {
          // animateTo的第二个参数表示动画的目标结果，该参数为空时表示按照geometryTransition转换
          // 指定由于闭包代码导致的状态变化插入过渡动效
          this.getUIContext().animateTo({ duration: 2000 }, () => {
            this.isShowFirst = !this.isShowFirst
          })
        })
      if (this.isShowFirst) { // 显示第一张图片
        Image(this.beginImage).width('100%').height(400)
          //.geometryTransition('picture') // 在同一个id的两个组件间转场
            // 设置转换效果。OPACITY表示转换不透明度
          .transition(TransitionEffect.OPACITY)
      } else { // 显示第二张图片
        Image(this.endImage).width('100%').height(400)
          //.geometryTransition('picture') // 在同一个id的两个组件间转场
            // 设置转换效果。OPACITY表示转换不透明度
          .transition(TransitionEffect.OPACITY)
      }
    }
    .width('100%').height('100%')
  }
}