@Entry
@Component
struct AttributeAnimationPage {
  @State index: number = 0; // 属性动画的序号
  private typeArray: Array<SelectOption> = [ { value: '无动画' },
    { value: '透明度动画' }, { value: '平移动画' },
    { value: '缩放动画' }, { value: '旋转动画' } ];
  // private typeArray: Array<SelectOption> = [
  //   { value: '无动画' }, { value: '透明度动画' }, { value: '平移动画' }, { value: '缩放动画' }, { value: '旋转动画' }, { value: '裁剪动画' }
  // ];
  // @State widthSize: number = 100
  // @State heightSize: number = 200
  @State alphaValue: number = 1; // 透明度
  @State translateOffset: number = 0; // 平移距离
  @State scaleRatio: number = 1; // 缩放比例
  @State rotateAngle: number = 0; // 旋转角度

  build() {
    Column() {
      Select(this.typeArray).width(200).font({ size: 18 })
        .alignSelf(ItemAlign.Start).selected($$this.index)
        .value(this.typeArray[this.index].value)
        .onSelect((index: number) => {
          if (this.index == 1) { // 透明度动画
            this.alphaValue = 0
          } else if (this.index == 2) { // 平移动画
            this.translateOffset = 200
          } else if (this.index == 3) { // 缩放动画
            this.scaleRatio = 0.5
          } else if (this.index == 4) { // 旋转动画
            this.rotateAngle = 180
          // } else if (this.index == 5) { // 裁剪动画
          //   this.heightSize = 50
          }
        })
      Shape() {
        Ellipse()
          .width(100).height(200).fill(Color.Blue).position({x:50, y:0})
          .opacity(this.alphaValue) // 不透明度
          .translate({x:this.translateOffset, y:0}) // 平移距离
          .scale({x:1, y:this.scaleRatio}) // 缩放比例
          .rotate({angle: this.rotateAngle}) // 旋转角度
            // 下面的animation接口处理灰度、平移、缩放和旋转动画
          .animation({
            duration: 2000, // 持续时间，单位毫秒
            curve: Curve.Linear, // 变化曲线。Linear表示线性，匀速播放。Ease表示先加速后减速。EaseIn表示加速。EaseOut表示减速。EaseInOut表示先加速后减速。FastOutSlowIn表示先快后慢。Rhythm表示节奏，前后慢中间快。Smooth表示平滑，匀速变化。Friction表示有摩擦，前快后慢。
            delay: 500, // 延迟间隔，单位毫秒
            iterations: 2, // 播放次数。为-1表示无限次循环
            playMode: PlayMode.Alternate, // 动画播放模式，默认播放完成后重头开始播放
            onFinish: () => {
              this.alphaValue = 1
              this.translateOffset = 0
              this.scaleRatio = 1
              this.rotateAngle = 0
            }
          })
      }
      .width('100%').height(200)
      // .width('100%').height(this.heightSize)
      // // 下面的animation处理裁剪动画
      // .animation({
      //   duration: 2000, // 持续时间，单位毫秒
      //   curve: Curve.Linear, // 变化曲线。Linear表示线性，匀速播放。Ease表示先加速后减速。EaseIn表示加速。EaseOut表示减速。EaseInOut表示先加速后减速。FastOutSlowIn表示先快后慢。Rhythm表示节奏，前后慢中间快。Smooth表示平滑，匀速变化。Friction表示有摩擦，前快后慢。
      //   delay: 500, // 延迟间隔，单位毫秒
      //   iterations: 2, // 播放次数。为-1表示无限次循环
      //   playMode: PlayMode.Alternate, // 动画播放模式，默认播放完成后重头开始播放
      //   onFinish: () => {
      //     this.heightSize = 200
      //   }
      // })
    }
    .width('100%').height('100%')
  }
}