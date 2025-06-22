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
      Text('15.1 智能语音')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('文本转语音').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/VoiceTTSPage' })
          })
        Button('语音识别').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/VoiceASRPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('文本朗读控件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextReaderPage' })
          })
        Button('智能字幕控件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/IntellectCaptionPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('15.2 智能视觉')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('扫描二维码').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/BarcodeScanPage' })
          })
        Button('生成二维码').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/BarcodeCreatePage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('文档扫描').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DocScannerPage' })
          })
        Button('文字识别').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextRecognizePage' })
          })
        Button('图像分类').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ImageClassifyPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('15.3 人脸识别')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('人脸检测').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/FaceDetectPage' })
          })
        Button('人脸比对').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/FaceComparePage' })
          })
        Button('活体检测').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LivenessDetectPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}