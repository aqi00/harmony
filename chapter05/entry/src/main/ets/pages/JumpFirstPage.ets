import { router } from '@kit.ArkUI';

@Entry
@Component
struct JumpFirstPage {
  router = this.getUIContext().getRouter();
  @State TAG: string = 'JumpFirstPage'; // 日志标记

  aboutToAppear() {
    console.info(this.TAG, 'aboutToAppear');
  }

  onDidBuild() {
    console.info(this.TAG, 'onDidBuild');
  }

  onPageShow() {
    console.info(this.TAG, 'onPageShow');
  }

  onPageHide() {
    console.info(this.TAG, 'onPageHide');
  }

  aboutToDisappear() {
    console.info(this.TAG, 'aboutToDisappear');
  }

  build() {
    Column() {
      Button('跳转到第二个页面')
        .width('100%').fontSize(17).margin({top: 10})
        .onClick(() => {
          // pushUrl简单跳转，不带跳转模式参数
          this.router.pushUrl({ url: 'pages/JumpSecondPage' })
        })
      Button('标准模式跳转到第二个页面')
        .width('100%').fontSize(17).margin({top: 10})
        .onClick(() => {
          // pushUrl默认采用Standard标准模式跳转，为Single表示单实例跳转
          this.router.pushUrl({ url: 'pages/JumpSecondPage' }, router.RouterMode.Standard)
        })
      Button('单实例跳转到第二个页面')
        .width('100%').fontSize(17).margin({top: 10})
        .onClick(() => {
          // pushUrl默认采用Standard标准模式跳转，为Single表示单实例跳转
          this.router.pushUrl({ url: 'pages/JumpSecondPage' }, router.RouterMode.Single)
        })
      Button('返回')
        .width('100%').fontSize(17).margin({top: 10})
        .onClick(() => {
          this.router.back() // 返回到前一个页面
        })
    }
    .width('100%')
  }
}