/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

class CalculateUtil {

  isEmpty(obj: object | string): boolean {
    return (typeof obj === 'undefined' || obj === null || obj === '');
  }

  /**
   * Determines whether it is an operator.
   *
   * @param value The symbol.
   * @return Is Operator.
   */
  isSymbol(value: string) {
    if (this.isEmpty(value)) {
      return ;
    }
    return ('+-×÷'.indexOf(value) !== -1);
  }

  /**
   * Get Operator Precedence.
   *
   * @param value The symbol.
   * @return Priority.
   */
  getPriority(value: string): number {
    if (this.isEmpty(value)) {
      return Priority.LOW;
    }
    let result = 0;
    switch (value) {
      case '+':
      case '-':
        result = Priority.MEDIUM;
        break;
      case '×':
      case '÷':
        result = Priority.HIGH;
        break;
      default:
        result = Priority.LOW;
        break;
    }
    return result;
  }

  /**
   * Determine the priority of addition, subtraction, multiplication, and division.
   *
   * @param arg1 Parameter 1.
   * @param arg2 Parameter 2.
   * @return Compare Priority Results.
   */
  comparePriority(arg1: string, arg2: string): boolean {
    if (this.isEmpty(arg1) || this.isEmpty(arg2)) {
      return false;
    }
    return (this.getPriority(arg1) <= this.getPriority(arg2));
  }

  /**
   * Expression Processing.
   *
   * @param expressions Expressions.
   */
  parseExpression(expressions: Array<string>): string {
    if (this.isEmpty(expressions)) {
      return 'NaN';
    }
    let len = expressions.length;
    let outputStack: string[] = [];
    let outputQueue: string[] = [];
    expressions.forEach((item: string, index: number) => {
      // Handle % in the expression
      if (item.indexOf('%') !== -1) {
        expressions[index] = (this.mulOrDiv(item.slice(0, item.length - 1),
          '100', '÷')).toString();
      }
      // Whether the last digit is an operator.
      if ((index === len - 1) && this.isSymbol(item)) {
        expressions.pop();
      }
    });
    while (expressions.length > 0) {
      let current: string | undefined = expressions.shift();
      if (current !== undefined) {
        if (this.isSymbol(current)) {
          // Processing addition, subtraction, multiplication and division.
          while (outputStack.length > 0 && this.comparePriority(current, outputStack[outputStack.length - 1])) {
            let popValue: string | undefined = outputStack.pop();
            if (popValue !== undefined) {
              outputQueue.push(popValue);
            }
          }
          outputStack.push(current);
        } else {
          // Processing the numbers.
          outputQueue.push(current);
        }
      }
    }
    while (outputStack.length > 0) {
      let popValue: string | undefined = outputStack.pop();
      if (popValue !== undefined) {
        outputQueue.push(popValue);
      }
    }
    return this.dealQueue(outputQueue);
  }

  /**
   * Processing expressions in queues.
   *
   * @param queue Expression Queue.
   * @return The end result.
   */
  dealQueue(queue: Array<string>): string {
    if (this.isEmpty(queue)) {
      return 'NaN';
    }
    let outputStack: string[] = [];
    while (queue.length > 0) {
      let current: string | undefined = queue.shift();
      if (current !== undefined) {
        if (!this.isSymbol(current)) {
          outputStack.push(current);
        } else {
          let second: string | undefined = outputStack.pop();
          let first: string | undefined = outputStack.pop();
          if (first !== undefined && second !== undefined) {
            let calResultValue: string = this.calResult(first, second, current)
            outputStack.push(calResultValue);
          }
        }
      }
    }
    if (outputStack.length !== 1) {
      return 'NaN';
    } else {
      let end: string = outputStack[0]?.endsWith('.') ?
        outputStack[0].substring(0, outputStack[0].length - 1) : outputStack[0];
      return end;
    }
  }

  /**
   * Calculation result.
   *
   * @param arg1 Number 1.
   * @param arg2 Number 2.
   * @param symbol Operators.
   * @return Calculation result.
   */
  calResult(arg1: string, arg2: string, symbol: string): string {
    if (this.isEmpty(arg1) || this.isEmpty(arg2) || this.isEmpty(symbol)) {
      return 'NaN';
    }
    let result = 0;
    switch (symbol) {
      case '+':
      case '-':
        result = this.add(arg1, arg2, symbol);
        break;
      case '×':
      case '÷':
        result = this.mulOrDiv(arg1, arg2, symbol);
        break;
      default:
        break;
    }
    return this.numberToScientificNotation(result);
  }

  /**
   * Addition and subtraction operation.
   *
   * @param arg1 Number 1.
   * @param arg2 Number 2.
   * @param symbol Operators.
   * @return Addition and subtraction results.
   */
  add(arg1: string, arg2: string, symbol: string): number {
    let addFlag = (symbol === '+');
    if (this.containScientificNotation(arg1) || this.containScientificNotation(arg2)) {
      if (addFlag) {
        return Number(arg1) + Number(arg2);
      }
      return Number(arg1) - Number(arg2);
    }
    arg1 = (arg1 === '0.') ? '0' : arg1;
    arg2 = (arg2 === '0.') ? '0' : arg2;
    let leftArr = arg1.split('.');
    let rightArr = arg2.split('.');
    let leftLen = leftArr.length > 1 ? leftArr[1] : '';
    let rightLen = rightArr.length > 1 ? rightArr[1] : '';
    let maxLen = Math.max(leftLen.length, rightLen.length);
    let multiples = Math.pow(10, maxLen);
    if (addFlag) {
      return Number(((Number(arg1) * multiples + Number(arg2) * multiples) / multiples).toFixed(maxLen));
    }
    return Number(((Number(arg1) * multiples - Number(arg2) * multiples) / multiples).toFixed(maxLen));
  }

  /**
   * multiplication and division operation.
   *
   * @param arg1 Number 1.
   * @param arg2 Number 2.
   * @param symbol Operators.
   * @return Multiply and divide result.
   */
  mulOrDiv(arg1: string, arg2: string, symbol: string): number {
    let mulFlag = (symbol === '×');
    if (this.containScientificNotation(arg1) || this.containScientificNotation(arg2)) {
      if (mulFlag) {
        return Number(arg1) * Number(arg2);
      }
      return Number(arg1) / Number(arg2);
    }
    let leftLen = arg1.split('.')[1] ? arg1.split('.')[1].length : 0;
    let rightLen = arg2.split('.')[1] ? arg2.split('.')[1].length : 0;
    if (mulFlag) {
      return Number(arg1.replace('.', '')) *
        Number(arg2.replace('.', '')) / Math.pow(10, leftLen + rightLen);
    }
    return Number(arg1.replace('.', '')) /
      (Number(arg2.replace('.', '')) / Math.pow(10, rightLen - leftLen));
  }

  /**
   * Whether the operand contains scientific notation
   *
   * @param arg Number.
   * @return Whether scientific notation is included
   */
  containScientificNotation(arg: string) {
    return (arg.indexOf('e') !== -1);
  }

  /**
   * Results converted to scientific notation.
   *
   * @param result Digital Results.
   */
  numberToScientificNotation(result: number) {
    if (result === Number.NEGATIVE_INFINITY || result === Number.POSITIVE_INFINITY) {
      return 'NaN';
    }
    let resultStr = JSON.stringify(result);
    if (this.containScientificNotation(resultStr)) {
      return resultStr;
    }
    let prefixNumber = (resultStr.indexOf('-') === -1) ? 1 : -1;
    result *= prefixNumber;
    if (resultStr.replace('.', '').replace('-', '').length <
      16) {
      return resultStr;
    }
    let suffix = (Math.floor(Math.log(result) / Math.LN10));
    let prefix = (result * Math.pow(10, -suffix) * prefixNumber);
    return (prefix + 'e' + suffix);
  }
}

enum Priority {
  HIGH = 2,
  MEDIUM = 1,
  LOW = 0
}

export default new CalculateUtil();