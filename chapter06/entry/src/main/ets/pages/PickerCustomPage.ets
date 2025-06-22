import { CustomInputDialog } from '../view/CustomInputDialog'

@Entry
@Component
struct PickerCustomPage {
  @State result: string = '';
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomInputDialog({
      cancel: (): void => this.cancel(),
      confirm: (nickName: string): void => this.confirm(nickName)
    }),
    customStyle: false, // 是否自定义样式
    alignment: DialogAlignment.Center // 对话框的对齐方式
  });

  cancel() {
    console.info('CustomInputDialog:cancel()')
  }

  confirm(nickName: string) {
    console.info('CustomInputDialog:confirm()')
    this.result = `您输入的昵称为：${nickName}`
  }

  build() {
    Column() {
      Button('打开自定义对话框').width('100%').margin(5).fontSize(18)
        .onClick(() => {
          this.dialogController.open() // 打开对话框
        })
      Text(this.result).width('100%').fontSize(18).padding(10)
    }.width('100%')
  }
}