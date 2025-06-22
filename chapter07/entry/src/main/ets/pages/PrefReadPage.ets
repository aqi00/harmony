import { preferences } from '@kit.ArkData';

@Entry
@Component
struct PrefReadPage {
  context = this.getUIContext().getHostContext();
  @State result: string = ''; // 首选项的读取结果

  private dataPref?: preferences.Preferences; // 首选项实例
  aboutToAppear() {
    let options: preferences.Options = { name: 'user_store' };
    this.dataPref = preferences.getPreferencesSync(this.context, options);
  }

  build() {
    Column() {
      Button('从首选项读取数据').fontSize(18).width('100%')
        .onClick(() => {
          this.result = '首选项保存的内容如下：'
          let map = this.dataPref?.getAllSync() as Record<string, Object>;
          let keys = Object.keys(map); // 获取键名数组
          for (let key of keys) {
            this.result = this.result + '\n　' + key + '的取值为' + map[key]
          }
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').padding(5)
  }
}