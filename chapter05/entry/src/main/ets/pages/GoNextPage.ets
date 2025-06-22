import { router } from '@kit.ArkUI';

@Entry
@Component
struct GoNextPage {
  router = this.getUIContext().getRouter();
  @State TAG: string = 'GoNextPage';

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
      Text('<').width('100%').fontSize(50).padding({ left:10 })
        .onClick(() => {
          this.router.back() // 返回到前一个页面
        })
      Button('返回').width('100%').fontSize(17)
        .onClick(() => {
          this.router.back() // 返回到前一个页面
        })
    }
    .width('100%')
  }
}