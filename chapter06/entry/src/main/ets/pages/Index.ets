import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('6.1 图像显示')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('图像组件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ImageViewPage' })
          })
        Button('九宫格特效').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ImageResizablePage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('占位组件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ImageSimplePage' })
          })
        Button('几何图形').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ImageShapePage' })
          })
        Button('文本混合图像').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ImageSpanPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('6.2 选择按钮')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('复选框').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ChooseCheckboxPage' })
          })
        Button('开关组件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ChooseTooglePage' })
          })
        Button('单选框').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ChooseRadioPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('6.3 文本输入')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('单行输入框').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextInputPage' })
          })
        Button('多行输入框').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextAreaPage' })
          })
        Button('双向绑定').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextBindPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('文本搜索框').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextSearchPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('6.4 挑选组件')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('挑选日期').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PickerDatePage' })
          })
        Button('挑选时间').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PickerTimePage' })
          })
        Button('挑选日历').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PickerCalendarPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('挑选文本').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PickerTextPage' })
          })
        Button('自定义弹窗').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PickerCustomPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('6.5 实战项目：找回密码')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('登录页面').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LoginMainPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}