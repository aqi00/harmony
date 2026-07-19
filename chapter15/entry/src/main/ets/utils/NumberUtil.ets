
// 运算结果结构
class OperateResult {
  result: number // 结果数字
  maxUnit: number // 最大单位
  constructor(result: number, maxUnit: number) {
    this.result = result
    this.maxUnit = maxUnit
  }
}

export class NumberUtil {
  // 根据计算式描述与运算符，判断该式子的左操作数和右操作数
  public static getOperands(str: string, operator: string): number[] {
    let textTemplate = /^(0|1|2|3|4|5|6|7|8|9|零|一|二|三|四|五|六|七|八|九|十|百|千|万|亿|两|幺)+$/
    let equalPos = str.lastIndexOf('等于')
    let operatorPos = str.lastIndexOf(operator)
    let secondNum = ''
    for (let i = equalPos - 1; i >= 0; i--) {
      let sub = str.substring(i, equalPos)
      let secondResult = textTemplate.test(sub)
      console.info('sub='+sub+',secondResult='+secondResult)
      if (!secondResult) {
        break
      }
      secondNum = sub
    }
    if (secondNum.length == 0) {
      return []
    }
    let firstNum = ''
    for (let i = operatorPos - 1; i >= 0; i--) {
      let sub = str.substring(i, operatorPos)
      let firstResult = textTemplate.test(sub)
      //console.info('sub='+sub+',firstResult='+firstResult)
      if (!firstResult) {
        break
      }
      firstNum = sub
    }
    if (firstNum.length == 0) {
      return []
    }
    let numberTemplate = /^(0|1|2|3|4|5|6|7|8|9)+$/
    console.info('firstNum=' + firstNum + ',secondNum=' + secondNum)
    let firstOperand = numberTemplate.test(firstNum) ?
      Number(firstNum) : NumberUtil.cnNumToLong(firstNum)
    let secondOperand = numberTemplate.test(secondNum) ?
      Number(secondNum) : NumberUtil.cnNumToLong(secondNum)
    console.info('firstOperand=' + firstOperand + ',secondOperand=' + secondOperand)
    return [firstOperand, secondOperand]
  }

  // 中文数字转为长整型数字
  public static cnNumToLong(chineseNumber: string): number {
    let cnNumberStr = '零一二三四五六七八九两幺'
    let numberStr = '0123456789'
    let numberAmountArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 2, 1]
    let cnUintStr = '十百千万亿'
    let unitAmountArray = [10, 100, 1000, 10000, 10000 * 10000]
    let resultList: OperateResult[] = []
    for (let i = 0; i < chineseNumber.length; i++) {
      let ch = chineseNumber.charAt(i)
      let numberPos = Math.max(cnNumberStr.indexOf(ch), numberStr.indexOf(ch))
      let unitPos = cnUintStr.indexOf(ch)
      let number = 1
      let unit = 1
      if (numberPos >= 0) {
        number = numberAmountArray[numberPos]
      } else if (unitPos >= 0) {
        unit = unitAmountArray[unitPos]
      } else {
        continue
      }
      let size = resultList.length
      if (size > 0 && resultList[size-1].maxUnit == 1 && unit == 1) {
        for (let j = size - 1; j >= 0; j--) {
          let element = resultList[j]
          if (element.maxUnit <= 100) {
            element.result *= 10
            element.maxUnit *= 10
            resultList[j] = element
          }
        }

        resultList.push(new OperateResult(number, unit))
        continue
      }
      let greaterPos = -1
      for (let j = 0; j < size; j++) {
        let element = resultList[j]
        //console.info('for element.result='+element.result+',element.maxUnit='+element.maxUnit)
        if (element.maxUnit <= unit) {
          greaterPos = j
          break
        }
      }
      console.info('greaterPos=' + greaterPos)
      if (greaterPos >= 0) {
        let tempResult = 0
        for (let j = size - 1; j >= greaterPos; j--) {
          let element = resultList[j]
          tempResult += element.result
          resultList.splice(j, 1)
        }
        resultList.push(new OperateResult(tempResult * unit, unit))
      } else {
        resultList.push(new OperateResult(number * unit, unit))
      }
    }
    let finalResult = 0
    for (let element of resultList) {
      //console.info('element.result='+element.result+',element.maxUnit='+element.maxUnit)
      finalResult += element.result
    }
    //console.info('finalResult='+finalResult)
    return finalResult
  }

  // 去掉小数字符串末尾的0
  public static removeTailZero(result: string): string {
    if (result.includes('.')) { // 是小数
      while (true) {
        if (result.charAt(result.length - 1) == '0') {
          result = result.substring(0, result.length - 1)
        } else {
          if (result.endsWith('.')) {
            result = result.substring(0, result.length - 1)
          }
          break
        }
      }
    }
    return result
  }
}