
class UserBranch {
  name: string
  isMale: boolean = true
  age: number

  // 类的字段要么在声明时赋值，要么在构造方法中赋值，不允许出现未初始化的字段
  constructor() {
    this.name = ''
    this.age = 0
  }

  public greet() {
    console.info('你好')
  }
}

function testBranch() {
  let xiaoQiang: UserBranch|undefined
  // 如果xiaoQiang非空，就向他问好
  if (xiaoQiang) {
    xiaoQiang.greet() // 调用对象的greet方法
  }
  // 对象名称后面加上冒号，相当于上面的if非空判断
  xiaoQiang?.greet()
  // 对象名称后面加上感叹号，表示跳过if判断，直接执行后面的greet方法
  // 请确保该对象真的非空，否则慎用感叹号，因为执行空对象的方法会扔出异常
  // xiaoQiang!.greet()

  let user = new UserBranch()
  // 如果用户是男性，就叫他“大哥”；如果用户是女性，就叫她“大姐”
  if (user.isMale) {
    user.name = '大哥'
  } else {
    user.name = '大姐'
  }
  // 三目运算符“?:”相当于上面的if/else分支结构
  user.name = user.isMale ? '大哥' : '大姐'
}

@Entry
@Component
struct ControlBranchPage {
  @State message: string = 'Hello World';

  aboutToAppear() {
    testBranch()
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('ControlBranchPageHelloWorld')
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