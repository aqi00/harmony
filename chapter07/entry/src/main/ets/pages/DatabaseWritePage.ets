import { UserInfo } from '../entity/UserInfo'
import { UserDB } from '../entity/UserDB'
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct DatabaseWritePage {
  promptAction = this.getUIContext().getPromptAction();
  @State name: string = ''; // 姓名
  @State age: number = 0; // 年龄
  @State stature: number = 0.0; // 身高
  @State weight: number = 0.0; // 体重
  @State ismarried: boolean = false; // 婚否

  private user_db: UserDB = new UserDB(); // 创建一个用户数据库实例

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
      Button('保存到数据库').fontSize(18).width('100%')
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
            let user_info = new UserInfo()
            user_info.name = this.name
            user_info.age = this.age
            user_info.stature = this.stature
            user_info.weight = this.weight
            user_info.ismarried = this.ismarried
            this.user_db.insert(user_info) // 向用户数据库插入一条记录
            this.promptAction.showToast({message: '成功把数据保存到数据库'})
          }
        })
    }
    .width('100%').padding(5)
  }
}