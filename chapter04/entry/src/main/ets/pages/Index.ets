import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('4.1 文本显示')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('文本组件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextViewPage' })
          })
        Button('文本大小').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextSizePage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('文本颜色').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextColorPage' })
          })
        Button('文本字体').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextFontPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('4.2 组件基础')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('组件宽高').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ViewSizePage' })
          })
        Button('宽高权重').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ViewWeightPage' })
          })
        Button('空白间隔').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ViewMarginPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('对齐方式').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ViewGravityPage' })
          })
        Button('文本对齐').fontSize(16) .layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TextGravityPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('4.3 常用容器')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('堆叠容器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LayoutStackPage' })
          })
        Button('相对容器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LayoutRelativePage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('弹性容器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LayoutFlexPage' })
          })
        Button('滚动容器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LayoutScrollPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('4.4 按钮触控')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('按钮类型').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ButtonTypePage' })
          })
        Button('按钮点击').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ButtonClickPage' })
          })
        Button('数据绑定').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ButtonStatePage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('4.5 实战项目：计算器')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('简单计算器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/CalculatorPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}