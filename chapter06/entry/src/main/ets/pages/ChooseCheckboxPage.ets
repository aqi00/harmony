@Entry
@Component
struct ChooseCheckboxPage {
  @State message: string = '请勾选某个复选框';

  build() {
    Column() {
      Text(this.message).fontSize(18).padding(5)
      Row() {
        Text('默认复选框').fontSize(18).margin({ right: 10 })
        Checkbox().height(30).width(30)
          .onChange((value: boolean) => {
            this.message = `您${value?'勾选':'取消勾选'}了默认复选框`
          })
      }
      Row() {
        Text('圆形复选框').fontSize(18).margin({ right: 10 })
        Checkbox().height(30).width(30)
          .select(false).selectedColor(Color.Red)
          .shape(CheckBoxShape.CIRCLE) // 圆形
          .onChange((value: boolean) => {
            this.message = `您${value?'勾选':'取消勾选'}了圆形复选框`
          })
      }
      Row() {
        Text('圆角方形复选框').fontSize(18).margin({ right: 10 })
        Checkbox().height(30).width(30)
          .select(false).selectedColor(Color.Blue)
          .shape(CheckBoxShape.ROUNDED_SQUARE) // 圆角方形
          .onChange((value: boolean) => {
            this.message = `您${value?'勾选':'取消勾选'}了圆角方形复选框`
          })
      }
    }.width('100%')
  }
}