import { router } from '@kit.ArkUI';

@Entry
@Component
struct GoRegisterPage {
  router = this.getUIContext().getRouter();
  @State TAG: string = 'GoRegisterPage';

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
      Button('注册成功').width('100%').fontSize(17)
        .onClick(() => {
          // replaceUrl会替换当前页面，使得下个页面无法返回到当前页面
          this.router.replaceUrl({ url: 'pages/GoNextPage' })
        })
    }
    .width('100%')
  }
}