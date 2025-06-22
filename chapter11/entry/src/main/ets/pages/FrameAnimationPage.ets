@Entry
@Component
struct FrameAnimationPage {
  @State imageArray: Array<ImageFrameInfo> = [
    { src: $r('app.media.flow_p1'), duration: 50 },
    { src: $r('app.media.flow_p2'), duration: 50 },
    { src: $r('app.media.flow_p3'), duration: 50 },
    { src: $r('app.media.flow_p4'), duration: 50 },
    { src: $r('app.media.flow_p5'), duration: 50 },
    { src: $r('app.media.flow_p6'), duration: 50 },
    { src: $r('app.media.flow_p7'), duration: 50 },
    { src: $r('app.media.flow_p8'), duration: 50 } ];

  build() {
    Column() {
      ImageAnimator().width('100%').height(600)
        .images(this.imageArray) // 图片帧列表
        .state(AnimationStatus.Running) // 播放状态。为Running表示一开始就播放动画
        .reverse(false) // 动画的播放方向。默认为false表示顺序播放，为true表示倒序播放
        .iterations(-1) // 动画的播放次数。默认为1表示只播放一次，为-1表示无限次播放
    }
    .width('100%').height('100%')
  }
}