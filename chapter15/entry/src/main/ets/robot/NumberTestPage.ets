import { NumberUtil } from '../utils/NumberUtil';
import { util } from '@kit.ArkTS';

@Entry
@Component
struct NumberTestPage {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    //let question = "一加一等于几";
    let question = "1-1等于几";
    let operands = NumberUtil.getOperands(question.replace('-','减'), '减')
    if (operands == null || operands.length < 2) {
      console.info('operands is null')
    } else {
      for (let item of operands) {
        console.info('item='+item)
      }
    }
    let quotient = 1.0 * 1 / 4
    console.info('quotient='+quotient)
    let result = ''
    if (Number.isInteger(quotient)) {
      result = ''+quotient
    } else {
      // 去掉小数字符串末尾的0
      result = NumberUtil.removeTailZero(quotient.toFixed(6))
    }
    console.info('result='+result)
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('NumberTestPageHelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}