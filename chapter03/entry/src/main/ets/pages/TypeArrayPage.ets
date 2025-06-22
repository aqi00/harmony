
function testArray() {
  let a: number[] = [1, 2, 3]
  let b: Array<number> = [1, 2, 3]
  let c = [1, 2, 3] // 如果声明数组变量时就给它赋值，则可省略变量名后面的数据类型，编译器会根据右边的赋值来确定数组类型
  let str: string[] = ['天', '地', '人']
  let str2 = ['你', '我', '他']

  let d: number[] // 如果声明数组变量时没给它赋值，就不能省略变量名后面的数组类型
  let e = [] // 这是个空数组，数组元素的数据类型待定
  let str3: string[]
  let str4: Array<string> = []

  let first = str2[0] // 获取第一个数组元素的值
  str2[2] = '她' // 修改第三个数组元素的值
}

@Entry
@Component
struct TypeArrayPage {
  @State message: string = 'Hello World';

  a: number[] = [1, 2, 3] // 在数据类型后面[]，表示该属性是个数组
  b: Array<number> = [1, 2, 3] // 采用“Array<数据类型>”也可声明数组，跟添加[]后缀的作用一样
  c = [1, 2, 3]
  str: string[] = ['天', '地', '人']
  str2: Array<string> = ['你', '我', '他']

  d?: number[] // 在属性名称后面加问号，表示该属性可为空值
  e = [] // 等号右侧直接用[]赋值，表示这是个空数组（数组长度为0）
  str3?: string[]
  str4: Array<string> = []

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('TypeArrayPageHelloWorld')
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