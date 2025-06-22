// 注意要先在EntryAbility.ets的onWindowStageCreate方法
// 内部windowStage.loadContent回调成功之后调用PersistentStorage.persistProp绑定持久化存储的属性
@Entry
@Component
struct PersistReadPage {
  @StorageProp('name') name: string = ''; // 姓名
  @StorageProp('age') age: number = 0; // 年龄
  @StorageProp('stature') stature: number = 0.0; // 身高
  @StorageProp('weight') weight: number = 0.0; // 体重
  @StorageProp('ismarried') ismarried: boolean = false; // 婚否
  @State data: string = ''; // 持久化存储的数据内容

  build() {
    Column() {
      Button('从持久化存储读取数据').fontSize(18).width('100%')
        .onClick(() => {
          this.data = '持久化存储保存的内容如下：\n' +
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