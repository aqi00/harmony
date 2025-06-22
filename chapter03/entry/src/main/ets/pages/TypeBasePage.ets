
function testBase() {
  let a: number = 1 // 声明变量要在前面添加let
  let b = 2.0 // 如果声明变量时就给它赋值，则可省略变量名后面的数据类型，编译器会根据右边的赋值来确定变量类型
  let bool: boolean = true
  let str: string = '你好'

  let c: number // 如果声明变量时没给它赋值，就不能省略后面的数据类型
  let boo2: boolean
  let str2: string
}

@Entry
@Component
struct TypeBasePage {
  @State message: string = 'Hello World';

  a: number = 1 // 整数用number类型
  b = 2.0 // 小数也用number类型
  bool: boolean = true // 布尔值用boolean类型。只有true和false两种取值
  str: string = '你好' // 字符串用string类型。支持单引号收纳，也支持双引号收纳

  c?: number // 属性变量要么初始化赋值，要么在变量名称后面加问号，表示该变量可为空值
  bool2?: boolean
  str2?: string
  str3: string|undefined = undefined // 或者通过“|”添加undefined类型，表示该属性变量可为未定义类型

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('TypeBasePageHelloWorld')
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