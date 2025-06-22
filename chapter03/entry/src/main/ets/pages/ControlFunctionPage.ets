
// 第二个参数event是个函数，外部调用时要实现该函数参数
function testFunction1(x: number, event: () => void) {
  console.info(`testFunction1 x=${x}`)
  event() // 这个函数参数没有输入
}

// 第二个参数event是个函数，外部调用时要实现该函数参数
function testFunction2(x: number, event: (y: number) => void) {
  console.info(`testFunction2 x=${x}`)
  event(x) // 这个函数参数输入了一个数字
}

// 第二个参数event是个函数，外部调用时要实现该函数参数
function testFunction3(x: number, event: () => string) {
  console.info(`testFunction3 x=${x}`)
  let result = event() // 这个函数参数存在返回值
  console.info(`testFunction3 result=${result}`)
}

@Entry
@Component
struct ControlFunctionPage {
  @State message: string = 'Hello World';

  aboutToAppear() {
    testFunction1(1, () => {
      console.info(`这是个没有输入的函数参数`)
    })
    testFunction2(2, (y) => {
      console.info(`这个函数参数的输入值为${y}`)
    })
    testFunction3(3, () => {
      console.info(`这个函数参数返回了一个字符串`)
      return '蓝天白云'
    })
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('ControlFunctionPageHelloWorld')
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