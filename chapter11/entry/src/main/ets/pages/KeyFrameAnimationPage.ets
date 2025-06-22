@Entry
@Component
struct KeyFrameAnimationPage {
  @State alphaValue: number = 1; // 透明度
  @State translateOffset: number = 0; // 平移距离
  @State rotateAngle: number = 0; // 旋转角度
  @State scaleRatio: number = 1; // 缩放比例

  build() {
    Column() {
      Button('播放关键帧动画').width('100%').fontSize(18)
        .onClick(() => {
          // 设置关键帧动画整体播放1次
          this.getUIContext().keyframeAnimateTo({ iterations: 1 }, [
          {
            duration: 1000, // 第一段透明度动画时长为1秒
            event: () => { this.alphaValue = 0.5 }
          }, {
            duration: 1000, // 第二段平移动画时长为1秒
            event: () => { this.translateOffset = 200 }
          }, {
            duration: 1000, // 第三段旋转动画时长为1秒
            event: () => { this.rotateAngle = 180 }
          }, {
            duration: 1000, // 第四段缩放动画时长为1秒
            event: () => { this.scaleRatio = 0.5 }
          }
        ])
      })
      Shape() {
        Ellipse()
          .width(100).height(200).fill(Color.Blue).position({x:10, y:0})
          .opacity(this.alphaValue) // 不透明度
          .translate({x:this.translateOffset, y:0}) // 平移距离
          .rotate({angle: this.rotateAngle}) // 旋转角度
          .scale({x:1, y:this.scaleRatio}) // 缩放比例
      }
      .width('100%').height(200)
    }
    .width('100%').height('100%')
  }
}