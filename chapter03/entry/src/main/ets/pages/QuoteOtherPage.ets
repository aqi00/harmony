// 通过关键字import引入外部的类，关键字from后面跟着待引入的文件路径，花括号{}中间填要引入的类名称（或接口名称）
import { User } from './User';

function test() {
  let user: User = new User() // 通过关键字new初始化一个某类的对象
  user.name = '张三' // 对象可以单独修改某个字段的值
  user.age = 20
  user.height = 170
}

@Entry
@Component
struct QuoteOtherPage {
  @State message: string = 'Hello World';

  user: User = new User() // 通过关键字new初始化一个某类的对象

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('QuoteOtherPageHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}