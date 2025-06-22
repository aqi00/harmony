@CustomDialog
export struct CustomInputDialog {
  @State nickName: string = '';
  // @CustomDialog组件必须声明CustomDialogController属性
  private dialogController?: CustomDialogController;
  // 取消接口，待实例化实现
  cancel: () => void = () => { }
  // 确认接口，待实例化实现
  confirm: (nickName: string) => void = () => { }

  build() {
    Column() {
      Text('请输入昵称').width('100%').margin(30)
        .fontSize(18).textAlign(TextAlign.Center)
      TextInput({ text: $$this.nickName, placeholder: '请输入昵称' })
        .height(40).margin(10).fontSize(18)
      Row() {
        Button('取消').fontSize(18).layoutWeight(1).margin(5)
          .backgroundColor(Color.Gray)
          .onClick(() => {
            this.dialogController?.close()
            this.cancel() // 响应取消事件
          })
        Button('确定').fontSize(18).layoutWeight(1).margin(5)
          .onClick(() => {
            this.dialogController?.close()
            this.confirm(this.nickName) // 响应确认事件
          })
      }.padding(10).margin({bottom:10})
    }
    .width('100%')
  }
}