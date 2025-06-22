// 通过getShared接口获取stage共享的LocalStorage实例
// 注意：LocalStorage.getShared()只在模拟器或者实机上才有效，在Previewer预览器中使用不生效。
// let storage_shared = LocalStorage.getShared()
//
// @Entry(storage_shared)
// 使用页面间共享的LocalStorage实例
@Entry({ useSharedStorage: true })
@Component
struct LocalReadPage {
  @LocalStorageProp('name') name: string = '';
  //name: string = storage.prop('name').get() as string
  @LocalStorageProp('age') age: number = 0;
  @LocalStorageProp('stature') stature: number = 0.0;
  @LocalStorageProp('weight') weight: number = 0.0;
  @LocalStorageProp('ismarried') ismarried: boolean = false;
  @State data: string = ''; // AppStorage存储的数据内容

  build() {
    Column() {
      Button('从页面存储读取数据').fontSize(18).width('100%')
        .onClick(() => {
          this.data = '页面存储保存的内容如下：\n' +
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