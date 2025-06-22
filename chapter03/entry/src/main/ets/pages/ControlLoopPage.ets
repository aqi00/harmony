
function testLoop() {
  let str: string[] = ['天', '地', '人']
  // 声明临时的递增变量i，通过数组下标获取数组元素
  for (let i=0; i<str.length; i++) {
    console.info(`i=${i}, value=${str[i]}`)
  }
  // 使用of关键字，轮询数组里的所有元素
  for (let item of str) {
    console.info(`item=${item}`)
  }
  let i = -1
  // 单个while的判断语句在每次循环之前执行
  while (++i < str.length) {
    console.info(`i=${i}, value=${str[i]}`)
  }
  let j = 0
  // do/while的判断语句在每次循环之后执行
  do {
    console.info(`j=${j}, value=${str[j]}`)
  } while (++j < str.length)
}

@Entry
@Component
struct ControlLoopPage {
  @State message: string = 'Hello World';

  aboutToAppear() {
    testLoop()
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('ControlLoopPageHelloWorld')
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