import { GlobalThis } from '../utils/GlobalThis';

@Entry
@Component
struct GlobalReadPage {
  @State result: string = ''; // 全局变量读取结果
  @State name: string = '';

  build() {
    Column() {
      Button('从全局变量读取数据').fontSize(18).width('100%')
        .onClick(() => {
          this.name = GlobalThis.getInstance().getValue('name') as string
          this.result = '全局变量保存的内容如下：'
          let map = GlobalThis.getInstance().getAll();
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