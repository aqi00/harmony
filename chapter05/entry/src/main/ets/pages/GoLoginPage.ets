import { router } from '@kit.ArkUI';

@Entry
@Component
struct GoLoginPage {
  router = this.getUIContext().getRouter();
  @State TAG: string = 'GoLoginPage';

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
      Button('登录成功').width('100%').fontSize(17)
        .onClick(() => {
          // pushUrl会把当前页面压入栈，使得下个页面能够返回到当前页面
          this.router.pushUrl({ url: 'pages/GoNextPage' })
        })
    }
    .width('100%')
  }
}