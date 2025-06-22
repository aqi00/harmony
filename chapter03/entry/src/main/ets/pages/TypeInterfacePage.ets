
// interface内部只能定义属性，不能定义方法
interface UserInterface {
  name: string
  isMale: boolean
  age: number
}

function testInterface() {
  // 给接口类型的变量赋值需要指定字段名称及其字段值。注意，不可省略变量名后面的接口类型
  let xiaoHong: UserInterface = {name:'小红', isMale:false, age:20}
  // 接口类型的变量不能单独修改某个字段值，只能对所有字段重新赋值
  xiaoHong = {name:'小红', isMale:false, age:30}

  let xiaoMing: UserInterface
}

@Entry
@Component
struct TypeInterfacePage {
  @State message: string = 'Hello World';

  // 给接口类型的属性赋值需要指定字段名称及其字段值。注意，不可省略属性名后面的接口类型
  xiaoHong: UserInterface = {name:'小红', isMale:false, age:20}
  xiaoMing?: UserInterface
  xiaoQiang?: UserInterface|undefined = undefined

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('TypeInterfacePageHelloWorld')
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