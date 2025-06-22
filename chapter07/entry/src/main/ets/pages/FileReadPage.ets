import { fileIo } from '@kit.CoreFileKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct FileReadPage {
  context = this.getUIContext().getHostContext();
  @State result: string = ''; // 文件读取结果

  private dataPref?: preferences.Preferences; // 首选项实例
  aboutToAppear() {
    let options: preferences.Options = { name: 'user_store' };
    this.dataPref = preferences.getPreferencesSync(this.context, options);
  }

  readFile(filePath: string) {
    console.info('read filePath: ' + filePath);
    let file = fileIo.openSync(filePath);

    // 获取文件信息
    fileIo.stat(file.fd, (err: Error, stat: fileIo.Stat) => {
      if (err) {
        console.error('get file info failed with error message: ' + err.message + ', error name: ' + err.name);
      } else {
        console.info('get file info succeed, the size of file is ' + stat.size);
      }
    });

    // 读取文件内容（readText和readLines只能读取沙箱文件）
    fileIo.readText(filePath).then((str: string) => {
      console.info('readText succeed:' + str);
      this.result = this.result + str
    }).catch((err: BusinessError) => {
      console.error('readText failed with error message: ' + err.message + ', error code: ' + err.code);
    }).finally(() => {
      fileIo.closeSync(file); // 关闭文件
    });
  }

  build() {
    Column() {
      Button('从文件读取数据').fontSize(18).width('100%')
        .onClick(() => {
          let filePath = this.dataPref?.getSync('filePath', '') as string
          this.result = `用户注册信息文件的读取路径为${filePath}\n`
          this.readFile(filePath)
        })
      Text(this.result).width('100%').fontSize(18).padding({top:5})
    }
    .width('100%').padding(5)
  }
}