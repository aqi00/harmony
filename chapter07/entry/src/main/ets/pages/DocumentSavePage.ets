import { fileIo } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct DocumentSavePage {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  promptAction = this.getUIContext().getPromptAction();
  @State result: string = ' '; // 文件写入结果
  @State name: string = ''; // 姓名
  @State age: number = 0; // 年龄
  @State stature: number = 0.0; // 身高
  @State weight: number = 0.0; // 体重
  @State ismarried: boolean = false; // 婚否

  saveFile(data: string) {
    let fileName = Utils.getNowDatetime() + '.txt'
    //let context = this.getUIContext().getHostContext() as common.UIAbilityContext
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [fileName];
    let documentPicker = new picker.DocumentViewPicker(this.context);
    documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      console.info('DocumentViewPicker.save successfully, documentSaveResult uri: ' + JSON.stringify(documentSaveResult));
      if (documentSaveResult.length == 0) {
        this.result = '请选择文件路径'
        return;
      }
      let dstPath = documentSaveResult[0]
      console.info("write filePath: " + dstPath);
      let file = fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      fileIo.write(file.fd, data).then((writeLen: number) => {
        console.info("write data to file succeed and size is:" + writeLen);
      }).catch((err: BusinessError) => {
        console.error("write data to file failed with error message: " + err.message + ", error code: " + err.code);
      }).finally(() => {
        fileIo.closeSync(file); // 关闭文件
      });
      this.result = '文件保存成功：'+dstPath
    }).catch((err: BusinessError) => {
      console.error('DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
      this.result = '文件保存失败'
    });
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
            //let update_time = Utils.getNowDatetime()
            let data = '用户信息如下：\n'
            data = data + '　姓名为' + this.name + '\n'
            data = data + '　年龄为' + this.age + '\n'
            data = data + '　身高为' + this.stature + '\n'
            data = data + '　体重为' + this.weight + '\n'
            data = data + '　婚否为' + this.ismarried + '\n'
            data = data + '　更新时间为' + Utils.getNowDatetime() + '\n'
            this.saveFile(data)
            this.promptAction.showToast({message: '成功把数据保存到文本文件'})
          }
        })
      Text(this.result).width('100%').padding(5).fontSize(18)
    }
    .width('100%').padding(5)
  }
}