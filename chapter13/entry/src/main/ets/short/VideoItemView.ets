import { promptAction } from '@kit.ArkUI';
import { VideoInfo } from '../entity/VideoInfo';
import { Constants } from '../constant/Constants';

@Component
export struct VideoItemView {
  promptAction = this.getUIContext().getPromptAction();
  @State info: VideoInfo | undefined = undefined; // 视频信息

  build() {
    if (this.info) {
      RelativeContainer() {
        Video({src: this.info.video.startsWith('http') ? this.info.video : Constants.URL_PREFIX+this.info.video})
          .width('100%').height('100%')
          .objectFit(ImageFit.Contain) // 组件区域包含整个视频画面
          .autoPlay(true) // 是否自动轮播
          .controls(false) // 是否显示控制条
          .loop(true) // 是否循环轮播
        Text(this.info.date+'  '+this.info.address).width('100%').padding(15)
          .fontSize(17).fontColor(Color.White).backgroundColor(Color.Transparent)
          .alignRules({
            left:{ anchor: '__container__', align: HorizontalAlign.Start},
            top:{ anchor: '__container__', align: VerticalAlign.Top},
          })
        Text(this.info.desc).width('100%').padding(15)
          .fontSize(17).fontColor(Color.White).backgroundColor(Color.Transparent)
          .alignRules({
            left:{ anchor: '__container__', align: HorizontalAlign.Start},
            bottom:{ anchor: '__container__', align: VerticalAlign.Bottom},
          })
        Column() {
          Image($r('app.media.icon_love')).width(50).height(50).margin(12)
            .onClick(() => {
              this.promptAction.showToast({message: '您已将该视频加入收藏'})
            })
          Image($r('app.media.icon_comment')).width(50).height(50).margin(12)
            .onClick(() => {
              this.promptAction.showToast({message: '您已对该视频发表评论'})
            })
          Image($r('app.media.icon_share')).width(50).height(50).margin(12)
            .onClick(() => {
              this.promptAction.showToast({message: '您已在朋友圈分享视频'})
            })
        }
        .margin({right:2, bottom:80})
        .alignRules({
          right:{ anchor: '__container__', align: HorizontalAlign.End},
          bottom:{ anchor: '__container__', align: VerticalAlign.Bottom},
        })
      }
      .width('100%').height('100%')
    }
  }
}