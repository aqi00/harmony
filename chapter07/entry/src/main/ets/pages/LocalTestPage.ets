
let storage = new LocalStorage();
storage.setOrCreate('name', 'caocao');
storage.setOrCreate('age', 30);
storage.setOrCreate('stature', '180');
storage.setOrCreate('weight', 70.5);
storage.setOrCreate('ismarried', true);

@Entry
@Component
struct LocalTestPage {
  @State data: string = ''; // LocalStorage存储的数据内容

  build() {
    Column() {
      Button('从页面存储读取测试数据').fontSize(18).width('100%')
        .onClick(() => {
          this.data = '页面存储保存的测试内容如下：\n' +
            '　姓名为' + storage.get('name') + '\n' +
            '　年龄为' + storage.get('age') + '\n' +
            '　身高为' + storage.get('stature') + '\n' +
            '　体重为' + storage.get('weight') + '\n' +
            '　婚否为' + storage.get('ismarried') + '\n'
        })
      Text(this.data).fontSize(18).padding(5).width('100%')
    }
    .width('100%').padding(5)
  }
}