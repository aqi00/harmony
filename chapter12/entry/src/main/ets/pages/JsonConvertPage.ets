import { UserInfo } from '../entity/UserInfo'
//import { JSON } from '@kit.ArkTS' // 注意预览器不支持来自@kit.ArkTS的JSON

@Entry
@Component
struct JsonConvertPage {
  private user: UserInfo = new UserInfo('阿三', 40, 170, 70);
  private jsonStr: string = JSON.stringify(this.user); // 把对象实例转换为JSON字符串
  @State result: string = ''; // 结果字符串

  build() {
    Column() {
      Row() {
        Button('原始JSON串').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.jsonStr = JSON.stringify(this.user) // 把对象实例转换为JSON字符串
            this.result = 'JSON串内容如下：\n' + this.jsonStr
          })
        Button('解析JSON串').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.user = JSON.parse(this.jsonStr) as UserInfo // 把JSON字符串解析为对象实例
            this.result = `从JSON串解析而来的用户信息如下：\n\t姓名=${this.user.name}\n\t年龄=${this.user.age}\n\t身高=${this.user.stature}\n\t体重=${this.user.weight}`
          })
      }.width('100%')
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%')
  }
}