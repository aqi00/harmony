@Entry
@Component
struct AppReadPage {
  @StorageProp('name') name: string = '';
  @StorageProp('age') age: number = 0;
  @StorageProp('stature') stature: number = 0.0;
  @StorageProp('weight') weight: number = 0.0;
  @StorageProp('ismarried') ismarried: boolean = false;
  @State data: string = ''; // AppStorage存储的数据内容

  build() {
    Column() {
      Button('从应用存储读取数据').fontSize(18).width('100%')
        .onClick(() => {
          this.data = '应用存储保存的内容如下：\n' +
            '　姓名为' + this.name + '\n' +
            '　年龄为' + this.age + '\n' +
            '　身高为' + this.stature + '\n' +
            '　体重为' + this.weight + '\n' +
            '　婚否为' + this.ismarried + '\n'
        })
      Text(this.data).width('100%').fontSize(18).padding(5)
    }
    .width('100%').padding(5)
  }
}