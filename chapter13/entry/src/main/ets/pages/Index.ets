import { router } from '@kit.ArkUI';
import { GlobalThis } from '../utils/GlobalThis';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  aboutToAppear(): void {
    GlobalThis.getInstance().setUIContext('ui_context', this.getUIContext());
  }

  build() {
    Column() {
      Text('13.1 相片')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('查看相机信息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/CameraInfoPage' })
          })
        Button('相机拍照').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/CameraPhotoPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('获取图片信息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ImageInfoPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('13.2 视频')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('视频选择器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/VideoPickerPage' })
          })
        Button('相机录像').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/CameraRecordPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('获取视频信息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/VideoInfoPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('13.3 音频')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('选择音频').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/AudioChoosePage' })
          })
        Button('音频播放').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/AudioPlayPage' })
          })
        Button('音频录制').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/AudioRecordPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('13.4 实战项目：短视频')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('仿抖音的短视频分享').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'short/ShortVideoPage' })
          })
      }.padding({top: 3, bottom: 3})
    }
    .width('100%').height('100%')
  }
}