@Entry
@Component
struct PickerTimePage {
  private selectedTime: Date = new Date('2024-12-29T08:00:00');
  @State result: string = ''; // 时间选择结果
  @State isMilitaryTime: boolean = false; // 是否为24小时制

  build() {
    Column() {
      Button('切换12/24小时制').width('100%').margin(10).fontSize(18)
        .onClick(() => {
          this.isMilitaryTime = !this.isMilitaryTime
        })
      TimePicker({ selected: this.selectedTime })
        .useMilitaryTime(this.isMilitaryTime) // 是否为24小时制
        .onChange((value: TimePickerResult) => {
          if (value.hour >= 0) {
            this.selectedTime.setHours(value.hour, value.minute)
            this.result = `您选择的时间为${value.hour}时${value.minute}分`
          }
        })
      Text(this.result).width('100%').padding(5).fontSize(18)

      Button('打开时间对话框').width('100%').margin({ top:50 }).fontSize(18)
        .onClick(() => {
          // API 18 之后的写法
          this.getUIContext().showTimePickerDialog({
            selected: this.selectedTime, // 默认的选中时间
            useMilitaryTime: this.isMilitaryTime, // 是否为24小时制
            onAccept: (value: TimePickerResult) => {
              this.selectedTime.setHours(value.hour, value.minute)
              console.info('TimePickerDialog:onAccept()' + value.toString())
              this.result = `您选择的时间为${value.hour}时${value.minute}分`
            },
            onChange: (value: TimePickerResult) => {
              console.info('TimePickerDialog:onChange()' + value.toString())
            }
          })
          // API 18 之前的写法，已废弃
          // TimePickerDialog.show({
          //   selected: this.selectedTime, // 默认的选中时间
          //   useMilitaryTime: this.isMilitaryTime, // 是否为24小时制
          //   onAccept: (value: TimePickerResult) => {
          //     this.selectedTime.setHours(value.hour, value.minute)
          //     console.info('TimePickerDialog:onAccept()' + value.toString())
          //     this.result = `您选择的时间为${value.hour}时${value.minute}分`
          //   },
          //   onChange: (value: TimePickerResult) => {
          //     console.info('TimePickerDialog:onChange()' + value.toString())
          //   }
          // })
        })
      Text(this.result).width('100%').padding(5).fontSize(18)
    }.width('100%')
  }
}