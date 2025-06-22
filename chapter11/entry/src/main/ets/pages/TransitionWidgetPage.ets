@Entry
@Component
struct TransitionWidgetPage {
  @State isShow: boolean = true; // 是否显示图片
  @State text: string = '隐藏图片'; // 控制按钮文本

  build() {
    Column() {
      Button(this.text).width('100%').fontSize(18)
        .onClick(() => {
          this.text = this.isShow ? '显示图片' : '隐藏图片'
          this.isShow = !this.isShow
        })
      if (this.isShow) {
        // Image的显示和消失配置为相同的过渡效果（出现和消失互为逆过程）
        // 出现时从指定的透明度为0、绕z轴旋转180度的状态，变为默认的透明度为1、旋转角为0的状态，透明度与旋转动画时长都为2000毫秒
        // 消失时从默认的透明度为1、旋转角为0的状态，变为指定的透明度为0、绕z轴旋转180度的状态，透明度与旋转动画时长都为2000毫秒
        Image($r('app.media.fade_begin'))
          .width(200).height(360).objectFit(ImageFit.Contain)
          .transition(TransitionEffect.opacity(0)
            .animation({ duration: 2000 })
            .combine(TransitionEffect.rotate({ angle: 180 }))
          )
      }
    }.width('100%')
  }
}