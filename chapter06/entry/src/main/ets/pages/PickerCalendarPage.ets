@Entry
@Component
struct PickerCalendarPage {
  @State result: string = ''; // 日历选择结果
  private selectedDate: Date = new Date(); // 默认选择日期

  build() {
    Column() {
      Text('日历选择器').fontSize(18).padding(5)
      Column() {
        CalendarPicker({ hintRadius: 10, selected: this.selectedDate })
          .margin(10).edgeAlign(CalendarAlign.END)
          .textStyle({ color: Color.Gray, font: { size: 20 } })
          .onChange((value: Date) => {
            console.info('CalendarPicker onChange:' + JSON.stringify(value))
            this.selectedDate = value
            this.result = '您选择的日期为' + value.toLocaleDateString()
          })
      }.alignItems(HorizontalAlign.End).width('100%')
      Text(this.result).width('100%').fontSize(18).padding(10)

      Button('打开日历对话框').width('100%').margin({ top:360 }).fontSize(18)
        .onClick(() => {
          CalendarPickerDialog.show({
            selected: this.selectedDate, // 默认的选中日期
            onAccept: (value: Date) => {
              this.selectedDate = value
              console.info('CalendarPickerDialog:onAccept()' + value.toString())
              this.result = '您选择的日期为' + value.toLocaleDateString()
            },
            onChange: (value: Date) => {
              console.info('CalendarPickerDialog:onChange()' + value.toString())
            }
          })
        })
      Text(this.result).width('100%').fontSize(18).padding(10)
    }.width('100%')
  }
}