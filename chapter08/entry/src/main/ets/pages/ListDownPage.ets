import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ListDownPage {
  promptAction = this.getUIContext().getPromptAction();
  @State index: number = 0; // 选中项的索引
  private planetArray: SelectOption[] = [
    { value: '水星', icon: $r('app.media.shuixing') },
    { value: '金星', icon: $r('app.media.jinxing') },
    { value: '地球', icon: $r('app.media.diqiu') },
    { value: '火星', icon: $r('app.media.huoxing') },
    { value: '木星', icon: $r('app.media.muxing') },
    { value: '土星', icon: $r('app.media.tuxing') }];

  build() {
    Column() {
      Select(this.planetArray).width('100%')
        .selected(this.index) // 默认选中哪一项
        .value(this.planetArray[this.index].value) // 默认展示文本
        .font({ size: 20, weight: 400 }) // 下拉框的文本样式
        .fontColor(Color.Black) // 下拉框的文本颜色
        .selectedOptionFont({ size: 20, weight: 400 }) // 选中项的字号
        .optionFont({ size: 20, weight: 400 }) // 可选项的字号
        //.space(8) // 下拉菜单项的文本与箭头之间的间距
        //.arrowPosition(ArrowPosition.END) // 下拉菜单项的文本与箭头之间的对齐方式
        //.menuAlign(MenuAlignType.START, {dx:0, dy:0}) // 下拉按钮与下拉菜单间的对齐方式
        //.optionWidth(200) // 下拉菜单项的宽度
        //.optionHeight(300) // 下拉菜单显示的最大高度。下拉菜单的默认最大高度是屏幕可用高度的80%，设置的菜单最大高度不能超过默认最大高度。
        .onSelect((index:number, text?: string | undefined) => {
          this.promptAction.showToast({message: '您选择了' + text})
          console.info('您选择了' + text)
          this.index = index;
        })
    }
    .width('50%')
  }
}