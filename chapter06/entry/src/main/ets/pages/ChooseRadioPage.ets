@Entry
@Component
struct ChooseRadioPage {
  @State message: string = '请选择某个单选框';

  build() {
    Column() {
      Text(this.message).fontSize(18).padding(5)
      Row() {
        Text('选项一（默认风格）').fontSize(18).margin({ right: 10 })
        Radio({ value: 'radio1', group: 'radioGroup' })
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.message = `您选择了选项一`
            }
          })
      }
      Row() {
        Text('选项二').fontSize(18).margin({ right: 10 })
        Radio({ value: 'radio2', group: 'radioGroup' }).checked(false)
          .radioStyle({ checkedBackgroundColor: Color.Red })
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.message = `您选择了选项二`
            }
          })
      }
      Row() {
        Text('选项三').fontSize(18).margin({ right: 10 })
        Radio({ value: 'radio3', group: 'radioGroup' }).checked(false)
          .radioStyle({ checkedBackgroundColor: Color.Blue })
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.message = `您选择了选项三`
            }
          })
      }
    }.width('100%')
  }
}