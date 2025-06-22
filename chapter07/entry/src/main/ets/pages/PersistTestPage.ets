
// persistProp仅做绑定属性用，如果某个属性之前已存有数据，persistProp就不会覆盖原数据
let firstProp = AppStorage.setOrCreate('firstProp', '甲');
PersistentStorage.persistProp('firstProp', '乙');

PersistentStorage.persistProp('secondProp', '甲');
let secondProp = AppStorage.setOrCreate('secondProp', '乙');

@Entry
@Component
struct PersistTestPage {
  @State data: string = ''; // 持久化存储的数据内容

  build() {
    Column() {
      Button('从持久存储读取测试数据').fontSize(18).width('100%')
        .onClick(() => {
          this.data = '持久存储保存的测试内容如下：\n' +
            '　第一个属性为' + AppStorage.get('firstProp') + '\n' +
            '　第二个属性为' + AppStorage.get('secondProp') + '\n'
        })
      Text(this.data).width('100%').fontSize(18).padding(5)
    }
    .width('100%').padding(5)
  }
}