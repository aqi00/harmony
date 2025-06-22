import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('3.1 变量与对象')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('基本类型').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TypeBasePage' })
          })
        Button('数组类型').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TypeArrayPage' })
          })
      }.padding({top: 3, bottom: 3})

      Row() {
        Button('接口类型').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TypeInterfacePage' })
          })
        Button('类及对象').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/TypeClassPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('3.2 控制结构')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('分支结构').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ControlBranchPage' })
          })
        Button('循环结构').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ControlLoopPage' })
          })
        Button('函数参数').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ControlFunctionPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('3.3 页面开发')
        .fontSize(18).margin({top:13, bottom:3})
      Button('引用外部实体').fontSize(16).width('100%').margin(3)
        .onClick(() => {
          this.router.pushUrl({ url: 'pages/QuoteOtherPage' })
        })
      Button('打开新页面').fontSize(16).width('100%').margin(3)
        .onClick(() => {
          this.router.pushUrl({ url: 'pages/TestPage' })
        })

    }
    .width('100%').height('100%')
  }
}