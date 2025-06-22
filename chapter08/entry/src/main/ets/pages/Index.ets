import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('8.1 列表类容器')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('下拉列表').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ListDownPage' })
          })
        Button('垂直列表').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ListVerticalPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('水平列表').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ListHorizontalPage' })
          })
        Button('复杂列表').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ListComplexPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('8.2 网格类容器')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('规则网格').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GridRegularPage' })
          })
        Button('不规则网格').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GridIrregularPage' })
          })
        Button('瀑布流网格').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/WaterFlowPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('8.3 滑块类容器')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('水平滑块').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SwiperHorizontalPage' })
          })
        Button('垂直滑块').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SwiperVerticalPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('数字指示器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SwiperDigitPage' })
          })
        Button('圆点指示器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SwiperDotPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('8.4 页签类容器')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('简单页签').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TabsSimplePage' })
          })
        Button('自定义页签').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TabsCustomPage' })
          })
        Button('底部页签栏').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TabsBottomPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('8.4 实战项目：电商首页')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('仿京东首页').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'business/DepartmentStorePage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}