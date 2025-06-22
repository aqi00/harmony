import { ChatInfo } from '../entity/ChatInfo';

@Component
export struct ChatItemView {
  @State info: ChatInfo|undefined = undefined;

  build() {
    if (this.info) {
      if (this.info.source == 1) {
        Row() {
          Blank().layoutWeight(1)
          Row() {
            Blank().layoutWeight(1)
            Column() {
              if (this.info.isGroup) {
                Text(this.info.name).fontSize(14).fontColor(Color.Gray).padding({ right: 5 })
              }
              if (this.info.type == 1) {
                Text(this.info.content).fontSize(16).padding(10)
                  .copyOption(CopyOptions.LocalDevice)
                  .backgroundImage($r('app.media.chat_me_bg'))
                  .backgroundImageSize({width: '100%', height: '100%'})
                  .backgroundImageResizable({ slice: { top: 20, left: 5, bottom: 5, right: 5 } })
              } else if (this.info.type == 2) {
                if (this.info.aspect! > 1) {
                  Image(this.info.pixelMap).width(150).height(150/this.info.aspect!).objectFit(ImageFit.Contain)
                } else {
                  Image(this.info.pixelMap).width(150*this.info.aspect!).height(150).objectFit(ImageFit.Contain)
                }
              }
            }.alignItems(HorizontalAlign.End)
          }.width('60%')
          Image(this.info.portrait).width(40).height(40).borderRadius(10)
            .objectFit(ImageFit.Contain).margin({left: 10})
        }.width('100%').margin({ top: 10 }).alignItems(VerticalAlign.Top).justifyContent(FlexAlign.End)
      } else if (this.info.source == 2) {
        Row() {
          Image(this.info.portrait).width(40).height(40).borderRadius(10)
            .objectFit(ImageFit.Contain).margin({right: 10})
          Row() {
            Column() {
              if (this.info.isGroup) {
                Text(this.info.name).fontSize(14).fontColor(Color.Gray).padding({ left: 5 })
              }
              if (this.info.type == 1) {
                Text(this.info.content).fontSize(16).padding(10)
                  .copyOption(CopyOptions.LocalDevice)
                  .backgroundImage($r('app.media.chat_other_bg'))
                  .backgroundImageSize({width: '100%', height: '100%'})
                  .backgroundImageResizable({ slice: { top: 20, left: 5, bottom: 5, right: 5 } })
              } else if (this.info.type == 2) {
                if (this.info.aspect! > 1) {
                  Image(this.info.pixelMap).width(150).height(150/this.info.aspect!).objectFit(ImageFit.Contain)
                } else {
                  Image(this.info.pixelMap).width(150*this.info.aspect!).height(150).objectFit(ImageFit.Contain)
                }
              }
            }.alignItems(HorizontalAlign.Start)
            Blank().layoutWeight(1)
          }.width('60%')
          Blank().layoutWeight(1)
        }.width('100%').margin({ top: 10 }).alignItems(VerticalAlign.Top).justifyContent(FlexAlign.Start)
      }
    }
  }
}