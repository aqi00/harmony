@Entry
@Component
struct PickerDatePage {
  private selectedDate: Date = new Date('2024-12-29'); // 默认日期
  @State result: string = ''; // 日期选择结果
  @State isLunar: boolean = false; // 是否为农历

  build() {
    Column() {
      Button('切换公历/农历').width('100%').margin(10).fontSize(18)
        .onClick(() => {
          this.isLunar = !this.isLunar
        })
      DatePicker({
        start: new Date('1970-1-1'), // 起始日期
        end: new Date('2100-1-1'), // 结束日期
        selected: this.selectedDate // 默认的选中日期
      })
        .lunar(this.isLunar) // 是否为农历
        .onDateChange((value: Date) => {
          this.selectedDate = value
          this.result = '您选择的日期为' + value.toLocaleDateString()
        })
      Text(this.result).width('100%').padding(5).fontSize(18)

      Button('打开日期对话框').width('100%').margin({ top:50 }).fontSize(18)
        .onClick(() => {
          // API 18 之后的写法
          this.getUIContext().showDatePickerDialog({
            start: new Date('2000-1-1'), // 起始日期
            end: new Date('2100-12-31'), // 结束日期
            selected: this.selectedDate, // 默认的选中日期
            showTime: false, // 是否显示时间
            useMilitaryTime: false, // 是否为24小时制
            onDateAccept: (value: Date) => {
              this.selectedDate = value
              console.info('DatePickerDialog:onDateAccept()' + value.toString())
              this.result = '您选择的日期为' + value.toLocaleDateString()
            },
            onDateChange: (value: Date) => {
              console.info('DatePickerDialog:onDateChange()' + value.toString())
            }
          })
          // API 18 之前的写法，已废弃
          // DatePickerDialog.show({
          //   start: new Date('2000-1-1'), // 起始日期
          //   end: new Date('2100-12-31'), // 结束日期
          //   selected: this.selectedDate, // 默认的选中日期
          //   showTime: false, // 是否显示时间
          //   useMilitaryTime: false, // 是否为24小时制
          //   onDateAccept: (value: Date) => {
          //     this.selectedDate = value
          //     console.info('DatePickerDialog:onDateAccept()' + value.toString())
          //     this.result = '您选择的日期为' + value.toLocaleDateString()
          //   },
          //   onDateChange: (value: Date) => {
          //     console.info('DatePickerDialog:onDateChange()' + value.toString())
          //   }
          // })
        })
      Text(this.result).width('100%').padding(5).fontSize(18)
    }.width('100%')
  }
}