import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter()

  build() {
    Column() {
      Row() {
        Button('PDF阅读器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PdfReaderPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('PDF管理器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PdfManagerPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('EPUB阅读器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/EpubReaderPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('MOBI阅读器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/MobiReaderPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('AZW3阅读器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/Azw3ReaderPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('DJVU阅读器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DjvuReaderPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('RTF阅读器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/RtfReaderPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}