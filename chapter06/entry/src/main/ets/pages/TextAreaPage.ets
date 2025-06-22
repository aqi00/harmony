@Entry
@Component
struct TextAreaPage {
  @State text: string = ''; // 初始文本
  @State result: string = ''; // 结果文本

  build() {
    Column() {
      Text('评价内容').fontSize(18).margin(5)
      TextArea({ text: this.text, placeholder: '请输入评价' })
        .width('100%').height(100)
        .fontSize(18).fontColor(Color.Black)
        .placeholderColor(Color.Grey) // 提示文本颜色
        .placeholderFont({ size: 18, weight: 400 }) // 提示文本字号
        .maxLength(320) // 最大字符长度
        .showCounter(true) // 是否显示计数值
        .maxLines(3) // 最大行数
        .type(TextAreaType.NORMAL) // 输入文本类型。NORMAL表示普通文本
        .onChange((value: string) => {
          this.result = '您输入的评价内容为：'+value
        })
      Text(this.result).width('100%').padding(5).fontSize(18)
    }
    .width('100%').margin(5)
  }
}