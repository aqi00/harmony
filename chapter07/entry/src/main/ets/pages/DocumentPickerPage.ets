import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';

@Entry
@Component
struct DocumentPickerPage {
  context = this.getUIContext().getHostContext() as common.Context;
  @State data: string = ''; // 文件数据内容
  @State document_path: string = ''; // 文件路径

  readFile(filePath: string) {
    console.info('read filePath: ' + filePath);
    this.data = `文件路径为${filePath}\n保存的内容如下：\n`
    // 以只读方式打开文件
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);

    // 获取文件信息
    fileIo.stat(file.fd, (err: Error, stat: fileIo.Stat) => {
      if (err) {
        console.error('get file info failed with error message: ' + err.message + ', error name: ' + err.name);
      } else {
        console.info('get file info succeed, the size of file is ' + stat.size);
      }
    });

    let arrayBuffer = new ArrayBuffer(4096);
    // read方法可以访问沙箱以外公共存储的文件
    fileIo.read(file.fd, arrayBuffer).then((readLen: number) => {
      console.info('read file data succeed');
      let buf = buffer.from(arrayBuffer, 0, readLen);
      console.info(`The content of file: ${buf.toString()}`);
      this.data = this.data + buf.toString()
    }).catch((err: BusinessError) => {
      console.error('read file data failed with error message: ' + err.message + ', error code: ' + err.code);
    }).finally(() => {
      fileIo.closeSync(file); // 关闭文件
    });
  }

  chooseDocument() {
    let documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    documentSelectOptions.fileSuffixFilters = ['.txt']
    let documentPicker = new picker.DocumentViewPicker(this.context);
    documentPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
      console.info('documentPicker.select successfully, documentSelectResult uri: ' + JSON.stringify(documentSelectResult));
      if (documentSelectResult.length == 0) {
        this.data = '请选择文件路径'
        return;
      }
      this.readFile(documentSelectResult[0])
    }).catch((err: BusinessError) => {
      console.error('documentPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('从文件读取数据').fontSize(18).width('100%')
        .onClick(() => {
          this.chooseDocument()
        })
      Text(this.data).width('100%').fontSize(18).padding(5)
    }
    .height('100%')
    .width('100%')
  }
}