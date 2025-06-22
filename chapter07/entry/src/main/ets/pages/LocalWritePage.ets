import { promptAction } from '@kit.ArkUI';

// 通过getShared接口获取stage共享的LocalStorage实例
// let storage_shared = LocalStorage.getShared()
//
// @Entry(storage_shared)
// 使用页面间共享的LocalStorage实例
@Entry({ useSharedStorage: true })
@Component
struct LocalWritePage {
  promptAction = this.getUIContext().getPromptAction();
  @LocalStorageLink('name') name: string = ''; // 姓名
  @LocalStorageLink('age') age: number = 0; // 年龄
  @LocalStorageLink('stature') stature: number = 0.0; // 身高
  @LocalStorageLink('weight') weight: number = 0.0; // 体重
  @LocalStorageLink('ismarried') ismarried: boolean = false; // 婚否

  build() {
    Column() {
      Row() {
        Text('姓名：').fontSize(18)
        TextInput({ text: $$this.name, placeholder: '请输入姓名' })
          .type(InputType.Normal).fontSize(18).layoutWeight(3)
      }.padding(5)
      Row() {
        Text('年龄：').fontSize(18)
        TextInput({ text: $$this.age, placeholder: '请输入年龄' })
          .type(InputType.Number).fontSize(18).layoutWeight(3)
      }.padding(5)
      Row() {
        Text('身高：').fontSize(18)
        TextInput({ text: $$this.stature, placeholder: '请输入身高' })
          .type(InputType.NUMBER_DECIMAL).fontSize(18).layoutWeight(3)
      }.padding(5)
      Row() {
        Text('体重：').fontSize(18)
        TextInput({ text: $$this.weight, placeholder: '请输入体重' })
          .type(InputType.NUMBER_DECIMAL).fontSize(18).layoutWeight(3)
      }.padding(5)
      Row() {
        Text('婚否：').fontSize(18)
        Checkbox().select($$this.ismarried)
      }.padding(5).alignSelf(ItemAlign.Start)
      Button('保存到页面存储').fontSize(18).width('100%')
        .onClick(() => {
          if (this.name == '') {
            this.promptAction.showToast({message: '请先填写姓名'})
          } else if (this.age == 0) {
            this.promptAction.showToast({message: '请先填写年龄'})
          } else if (this.stature == 0.0) {
            this.promptAction.showToast({message: '请先填写身高'})
          } else if (this.weight == 0.0) {
            this.promptAction.showToast({message: '请先填写体重'})
          } else {
            console.info(`姓名是${this.name}`)
            this.promptAction.showToast({message: '成功把数据保存到页面存储'})
          }
        })
    }
    .width('100%').padding(5)
  }
}