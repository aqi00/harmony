@Entry
@Component
struct ButtonStatePage {
  @State message: string = 'Hello World';
  @State enable: boolean = true; // 是否可用
  @State visible: boolean = true; // 是否可见
  @State enableText: string = '禁用按钮';
  @State visibleText: string = '隐藏按钮';

  build() {
      Column() {
        Text(this.message).fontSize(18)
        Button('改变文本内容').width('100%').fontSize(18).margin(5)
          .enabled(this.enable)
          .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.message = '您点击了按钮：'+Math.random()
          })
        Row() {
          Button(this.enableText).fontSize(18).layoutWeight(1)
            .onClick(() => {
              this.enable = !this.enable
              this.enableText = this.enable ? '禁用按钮' : '启用按钮'
            })
          Button(this.visibleText).fontSize(18).layoutWeight(1)
            .onClick(() => {
              this.visible = !this.visible
              this.visibleText = this.visible ? '隐藏按钮' : '显示按钮'
            })
        }.width('100%').margin(5)
      }
      .width('100%')
  }
}