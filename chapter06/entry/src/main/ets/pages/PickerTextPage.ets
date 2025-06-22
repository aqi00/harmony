@Entry
@Component
struct PickerTextPage {
  @State result: string = ''; // 文本选择结果
  private current: number = 0; // 选中项的索引
  private apfruits: string[] = ['红苹果', '青苹果', '丑苹果', '嘎啦果'];
  private orfruits: string[] = ['伦晚橙', '白沙橙', '脐橙', '纽荷尔橙'];
  private pefruits: string[] = ['水蜜桃', '黄桃', '脆桃', '杨桃'];
  private multi: string[][] = [this.apfruits, this.orfruits, this.pefruits];

  private cascade: TextCascadePickerRangeContent[] = [
    {
      text: '辽宁省',
      children: [{ text: '沈阳市', children: [{ text: '沈河区' }, { text: '和平区' }, { text: '浑南区' }] },
        { text: '大连市', children: [{ text: '中山区' }, { text: '金州区' }, { text: '长海县' }] }]
    },
    {
      text: '吉林省',
      children: [{ text: '长春市', children: [{ text: '南关区' }, { text: '宽城区' }, { text: '朝阳区' }] },
        { text: '四平市', children: [{ text: '铁西区' }, { text: '铁东区' }, { text: '梨树县' }] }]
    },
    {
      text: '黑龙江省',
      children: [{ text: '哈尔滨市', children: [{ text: '道里区' }, { text: '道外区' }, { text: '南岗区' }] },
        { text: '牡丹江市', children: [{ text: '东安区' }, { text: '西安区' }, { text: '爱民区' }] }]
    }
  ]

  build() {
    Scroll() {
      Column() {
        // 单列文本选择
        TextPicker({ range: this.apfruits, selected: this.current })
          .canLoop(true) // 是否可循环滚动
          .onChange((value: string | string[], index: number | number[]) => {
            console.info('Picker item changed, value: ' + value + ', index: ' + index)
            this.result = '您选择的水果为' + value
          }).margin(5)
        Text(this.result).width('100%').padding(10).fontSize(18)

        // // 多列文本选择
        // TextPicker({ range: this.multi })
        //   .onChange((value: string | string[], index: number | number[]) => {
        //     console.info('TextPicker 多列:onChange ' + JSON.stringify(value) + ', ' + 'index: ' + JSON.stringify(index))
        //   }).margin(5)
        // // 多列文本联动选择
        // TextPicker({ range: this.cascade })
        //   .onChange((value: string | string[], index: number | number[]) => {
        //     console.info('TextPicker 多列联动:onChange ' + JSON.stringify(value) + ', ' + 'index: ' + JSON.stringify(index))
        //   })

        Button('打开水果对话框').width('100%').margin({ top: 30 }).fontSize(18)
          .onClick(() => {
            // API 18 之后的写法
            this.getUIContext().showTextPickerDialog({
              range: this.apfruits, // 数据选择列表
              selected: this.current, // 默认选择哪一项
              canLoop: true, // 是否可循环滚动
              onAccept: (value: TextPickerResult) => {
                this.current = value.index as number
                console.info('TextPickerDialog:onAccept()' + value.toString())
                this.result = '您选择的水果为' + this.apfruits[this.current]
              },
              onChange: (value: TextPickerResult) => {
                console.info('TextPickerDialog:onChange()' + value.toString())
              }
            })
            // API 18 之前的写法，已废弃
            // TextPickerDialog.show({
            //   range: this.apfruits, // 数据选择列表
            //   selected: this.current, // 默认选择哪一项
            //   canLoop: true, // 是否可循环滚动
            //   onAccept: (value: TextPickerResult) => {
            //     this.current = value.index as number
            //     console.info('TextPickerDialog:onAccept()' + value.toString())
            //     this.result = '您选择的水果为' + this.apfruits[this.current]
            //   },
            //   onChange: (value: TextPickerResult) => {
            //     console.info('TextPickerDialog:onChange()' + value.toString())
            //   }
            // })
          })
        Text(this.result).width('100%').padding(10).fontSize(18)
      }
      .width('100%')
    }
  }
}