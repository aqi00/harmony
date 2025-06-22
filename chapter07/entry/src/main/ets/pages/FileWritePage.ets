import { fileIo } from '@kit.CoreFileKit';
import { preferences } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct FileWritePage {
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

  @State result: string = '';
  saveFile(data: string) {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext
    let filePath = context.filesDir + '/' + Utils.getNowDatetime() + '.txt';
    console.info('write filePath: ' + filePath);
    // 以可读可写方式打开目标文件
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
    // 写入文件内容
    fileIo.write(file.fd, data).then((writeLen: number) => {
      console.info('write data to file succeed and size is:' + writeLen);
    }).catch((err: BusinessError) => {
      console.error('write data to file failed with error message: ' + err.message + ', error code: ' + err.code);
    }).finally(() => {
      fileIo.closeSync(file); // 关闭文件
    });
    this.dataPref?.putSync('filePath', filePath)
    this.dataPref?.flush() // 持久化缓存中的首选项数据
    this.result = '用户注册信息文件的保存路径为' + filePath
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
      Button('保存到文件').fontSize(18).width('100%')
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
            let update_time = Utils.getNowDatetime()
            let data = '用户信息如下：\n'
            data = data + '　姓名为' + this.name + '\n'
            data = data + '　年龄为' + this.age + '\n'
            data = data + '　身高为' + this.stature + '\n'
            data = data + '　体重为' + this.weight + '\n'
            data = data + '　婚否为' + this.ismarried + '\n'
            data = data + '　更新时间为' + update_time + '\n'
            this.saveFile(data)
            this.promptAction.showToast({message: '成功把数据保存到文本文件'})
          }
        })
      Text(this.result).fontSize(18).width('100%').padding({top:5})
    }
    .width('100%').padding(5)
  }
}