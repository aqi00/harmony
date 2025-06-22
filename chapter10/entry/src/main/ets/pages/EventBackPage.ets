import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct EventBackPage {
  promptAction = this.getUIContext().getPromptAction();
  @State message: string = '请按返回键';
  private canBack: boolean = false; // 能否返回

  onBackPress() {
    console.info('按下了返回键')
    if (this.canBack) {
      // 返回false表示回到上个页面，返回true会留在当前页
      return false
    }
    this.canBack = !this.canBack
    this.promptAction.showToast({message: '再按一次返回键退出！'})
    // 返回true表示页面自己处理返回逻辑，不进行页面路由；
    // 返回false表示按照默认的路由返回逻辑，若不设置返回值就按照false处理。
    return true
  }

  build() {
    RelativeContainer() {
      Text(this.message).fontSize(25).margin({bottom: 150})
        .alignRules({
          middle:{ anchor: '__container__', align: HorizontalAlign.Center},
          bottom:{ anchor: '__container__', align: VerticalAlign.Bottom}
        })
    }
    .width('100%').height('100%')
  }
}