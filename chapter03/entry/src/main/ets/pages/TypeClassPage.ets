
// class内部既能定义属性，也能定义方法
class UserClass {
  name: string
  isMale: boolean = true
  age: number

  // 类的字段要么在声明时赋值，要么在构造方法中赋值，不允许出现未初始化的字段
  constructor() {
    this.name = ''
    this.age = 0
  }
}

function testClass() {
  let xiaoHong: UserClass = new UserClass() // 通过关键字new实例化UserClass类型的对象
  xiaoHong.name = '小红' // 对象可以单独修改某个字段的值
  xiaoHong.isMale = false
  xiaoHong.age = 20

  // 如果在声明对象时就给它赋值，则可省略对象名后面的类名称
  let xiaoMing = new UserClass()

  let xiaoQiang: UserClass
}

@Entry
@Component
struct TypeClassPage {
  @State message: string = 'Hello World';

  xiaoHong: UserClass = new UserClass() // 通过关键字new初始化一个某类的对象
  xiaoMing?: UserClass
  xiaoQiang: UserClass|undefined = undefined

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('TypeClassPageHelloWorld')
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