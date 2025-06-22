
// 在调用envProp之后，调用keys才会返回键名集合
let keys = Environment.keys()
for (let key of keys) {
  Environment.envProp(key, '')
}
Environment.envProp('languageCode', 'kr');
Environment.envProp('colorMode', 'yuv');
Environment.envProp('fontScale', '0');
Environment.envProp('fontWeightScale', '0');
Environment.envProp('layoutDirection', '0');
Environment.envProp('accessibilityEnabled', false);

@Entry
@Component
struct EnvironmentPage {
  @State data: string = ''; // 环境数据的读取结果

  build() {
    Column() {
      Button('从设备环境读取系统数据').fontSize(18).width('100%')
        .onClick(() => {
          console.info('keys length = '+keys.length)
          this.data = '设备环境保存的系统内容如下：\n'
          for (let i=0; i<keys.length; i++) {
            let value = AppStorage.get(keys[i]) as string
            this.data = `${this.data} 第${i+1}个属性名为${keys[i]}，值为${value}\n`
          }
          this.data = this.data + '应用存储保存的数据内容如下：\n'
          let iterator = AppStorage.keys()
          let result = iterator.next()
          while (!result.done) {
            let key = result.value
            if (!keys.includes(key)) {
              let value = AppStorage.get(key) as string
              this.data = `${this.data} ${key}属性值为${value}\n`
            }
            result = iterator.next()
          }
        })
      Text(this.data).fontSize(18).padding(5).width('100%')
    }
    .width('100%').padding(5)
  }
}