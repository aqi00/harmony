import { preferences } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct PrefWritePage {
  context = this.getUIContext().getHostContext();
  promptAction = this.getUIContext().getPromptAction();
  @State name: string = ''; // 姓名
  @State age: number = 0; // 年龄
  @State stature: number = 0.0; // 身高
  @State weight: number = 0.0; // 体重
  @State ismarried: boolean = false; // 婚否

  private dataPref?: preferences.Preferences; // 首选项实例
  aboutToAppear() {
    let options: preferences.Options = { name: 'user_store' };
    this.dataPref = preferences.getPreferencesSync(this.context, options);
  }

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
      Button('保存到首选项').fontSize(18).width('100%')
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
            this.dataPref?.putSync('name', this.name)
            this.dataPref?.putSync('age', this.age)
            this.dataPref?.putSync('stature', this.stature)
            this.dataPref?.putSync('weight', this.weight)
            this.dataPref?.putSync('ismarried', this.ismarried)
            this.dataPref?.flush() // 持久化缓存中的首选项数据
            this.promptAction.showToast({message: '成功把数据保存到首选项'})
          }
        })
    }
    .width('100%').padding(5)
  }
}