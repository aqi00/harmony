
AppStorage.setOrCreate('name', 'caocao');
AppStorage.setOrCreate('age', 30);
AppStorage.setOrCreate('stature', '180');
AppStorage.setOrCreate('weight', 70.5);
AppStorage.setOrCreate('ismarried', true);

@Entry
@Component
struct AppTestPage {
  @State data: string = ''; // AppStorage存储的数据内容

  build() {
    Column() {
      Button('从应用存储读取测试数据').fontSize(18).width('100%')
        .onClick(() => {
          this.data = '应用存储保存的测试内容如下：\n' +
            '　姓名为' + AppStorage.get('name') + '\n' +
            '　年龄为' + AppStorage.get('age') + '\n' +
            '　身高为' + AppStorage.get('stature') + '\n' +
            '　体重为' + AppStorage.get('weight') + '\n' +
            '　婚否为' + AppStorage.get('ismarried') + '\n'
        })
      Text(this.data).width('100%').fontSize(18).padding(5)
    }
    .width('100%').padding(5)
  }
}