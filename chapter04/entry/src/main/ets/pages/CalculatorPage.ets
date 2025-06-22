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

import CalculateUtil from '../utils/CalculateUtil';
import keysModel from '../model/PresskeysViewModel';
import { PressKeysBean } from '../model/PressKeysItem';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct CalculatorPage {
  @State inputValue: string = ''; // 输入内容
  @State calValue: string = ''; // 计算结果
  private expressions: string[] = []; // 表达式列表
  promptAction = this.getUIContext().getPromptAction();

  build() {
    Column() {
      Column() {
        Text(this.resultFormat(this.inputValue))
          .height('100%').textAlign(TextAlign.End)
          .fontSize( (this.inputValue.length > 9) ? '32fp' : '64fp' )
          .fontColor(Color.Black).backgroundColor('#F5F5F5')
      }
      .width('100%').height(86).margin({ right: 20, top: 120 })
      .alignItems(HorizontalAlign.End)
      Column() {
        Text(this.resultFormat(this.calValue))
          .fontSize('32fp').fontColor(Color.Gray)
      }
      .width('100%').height(43).margin({ right: 20, bottom: 60 })
      .alignItems(HorizontalAlign.End)

      Column() {
        Row() {
          ForEach(keysModel.getPressKeys(), (columnItem: Array<PressKeysBean>, columnItemIndex?: number) => {
            Column() {
              ForEach(columnItem, (keyItem: PressKeysBean, keyItemIndex?: number) => {
                Column() {
                  Column() {
                    if (keyItem.flag === 0) {
                      Text(keyItem.text)
                        .fontSize('32fp').fontColor(Color.Blue)
                        .width(keyItem.width).height(keyItem.height)
                    } else {
                      Text(keyItem.value)
                        .fontSize( (keyItem.value === '.') ? '42fp' : '32fp' )
                        .width(keyItem.width).height(keyItem.height)
                    }
                  }
                  .width(70)
                  .height(
                    ((columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
                      (keyItemIndex === (columnItem.length - 1))) ? 125 : 60
                  )
                  .borderRadius(24).backgroundColor(Color.White)
                  .alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    if (!this.checkValidate(keyItem.flag, keyItem.value)) {
                      return;
                    }
                    if (keyItem.flag === 0) {
                      this.inputSymbol(keyItem.value);
                    } else {
                      this.inputNumber(keyItem.value);
                    }
                  })
                }
                .layoutWeight(
                  ((columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
                    (keyItemIndex === (columnItem.length - 1))) ? 2 : 1
                )
                .width('100%').justifyContent(FlexAlign.Center)
              })
            }
            .layoutWeight(1).margin({ top: 70, bottom: 40 })
          })
        }
        .height('100%').margin({ left: 19, right: 19 })
        .alignItems(VerticalAlign.Top)
      }
      .layoutWeight(1).width('100%').backgroundColor('#F8F8FF')
    }
    .height('100%').backgroundColor('#F5F5F5')
  }

  checkValidate(flag: number, value: string) {
    let len = this.expressions.length;
    let last = len > 0 ? this.expressions[len - 1] : '';
    console.info('flag='+flag+', last='+last+', value='+value)
    if (flag === 0) { // 当前输入运算符
      if (isNaN(Number(last)) && value === 'equal') {
        this.promptAction.showToast({message: '请输入操作数'})
        return false;
      }
    } else { // 当前输入操作数
      if (last === '÷' && value === '0') {
        this.promptAction.showToast({message: '除数不能为零'})
        return false;
      }
      if (last.endsWith('.') && value === '.') {
        this.promptAction.showToast({message: '不能输入两个连续的小数点'})
        return false;
      }
    }
    return true
  }

  // 输入标点符号
  inputSymbol(value: string) {
    if (CalculateUtil.isEmpty(value)) {
      return;
    }
    let len = this.expressions.length;
    switch (value) {
      case 'clean':
        this.expressions = [];
        this.calValue = '';
        break;
      case 'delete':
        this.inputDelete(len);
        break;
      case 'equal':
        if (len === 0) {
          return;
        }
        this.getResult().then((result: boolean) => {
          if (!result) {
            return;
          }
          this.inputValue = this.calValue;
          this.calValue = '';
          this.expressions = [];
          this.expressions.push(this.inputValue);
        })
        break;
      default:
        this.inputOperators(len, value);
        break;
    }
    this.formatInputValue();
  }

  // 输入数字
  inputNumber(value: string) {
    if (CalculateUtil.isEmpty(value)) {
      return;
    }
    let len = this.expressions.length;
    let last = len > 0 ? this.expressions[len - 1] : '';
    let secondLast = len > 1 ? this.expressions[len - 2] : undefined;
    if (!this.validateEnter(last, value)) {
      return;
    }
    if (!last) {
      this.expressions.push(value);
    } else if (!secondLast) {
      this.expressions[len - 1] += value;
    }
    if (secondLast && CalculateUtil.isSymbol(secondLast)) {
      this.expressions[len -1] += value;
    }
    if (secondLast && !CalculateUtil.isSymbol(secondLast)) {
      this.expressions.push(value);
    }
    this.formatInputValue();
    if (value !== '.') {
      this.getResult();
    }
  }

  // 校验输入是否合理
  validateEnter(last: string, value: string) {
    if (!last && value === '%') {
      return false;
    }
    if ((last === '-') && (value === '%')) {
      return false;
    }
    if (last.endsWith('%')) {
      return false;
    }
    if ((last.indexOf('.') !== -1) && (value === '.')) {
      return false;
    }
    if ((last === '0') && (value !== '.') &&
      (value !== '%')) {
      return false;
    }
    return true;
  }

  // 删除上次的输入
  inputDelete(len: number) {
    if (len === 0) {
      return;
    }
    let last = this.expressions[len - 1];
    let lastLen = last.length;
    if (lastLen === 1) {
      this.expressions.pop();
      len = this.expressions.length;
    } else {
      this.expressions[len - 1] = last.slice(0, last.length - 1);
    }
    if (len === 0) {
      this.inputValue = '';
      this.calValue = '';
      return;
    }
    if (!CalculateUtil.isSymbol(this.expressions[len - 1])) {
      this.getResult();
    }
  }

  // 输入运算符
  inputOperators(len: number, value: string) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    let secondLast = len > 1 ? this.expressions[len - 2] : undefined;
    if (!last && (value === 'minus')) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!last) {
      return;
    }
    if (!CalculateUtil.isSymbol(last)) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if ((value === 'minus') &&
      (last === '-' || last === '+')) {
      this.expressions.pop();
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!secondLast) {
      return;
    }
    if (value !== 'minus') {
      this.expressions.pop();
    }
    if (CalculateUtil.isSymbol(secondLast)) {
      this.expressions.pop();
    }
    this.expressions.push(this.getSymbol(value));
  }

  // 获取运算符
  getSymbol(value: string) {
    if (CalculateUtil.isEmpty(value)) {
      return '';
    }
    let symbol = '';
    switch (value) {
      case 'add':
        symbol = '+';
        break;
      case 'minus':
        symbol = '-';
        break;
      case 'multiply':
        symbol = '×';
        break;
      case 'divide':
        symbol = '÷';
        break;
      default:
        break;
    }
    return symbol;
  }

  // 完整复制表达式
  deepCopy(): Array<string> {
    let copyExpressions: Array<string> = Array.from(this.expressions);
    return copyExpressions;
  }

  // 获取运算结果
  async getResult() {
    let calResult = CalculateUtil.parseExpression(this.deepCopy());
    if (calResult === 'NaN') {
      this.calValue = '错误';
      return false;
    }
    this.calValue = calResult;
    return true;
  }

  // 格式化运算结果
  resultFormat(value: string) {
    let reg = (value.indexOf('.') > -1) ? new RegExp("/(\d)(?=(\d{3})+\.)/g") : new RegExp("/(\d)(?=(?:\d{3})+$)/g");
    return value.replace(reg, '$1,');
  }

  // 格式化输入数字
  formatInputValue() {
    let deepExpressions: Array<string> = [];
    this.deepCopy().forEach((item: string, index: number) => {
      deepExpressions[index] = this.resultFormat(item);
    });
    this.inputValue = deepExpressions.join('');
  }
}