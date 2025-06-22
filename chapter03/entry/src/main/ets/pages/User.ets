// 提供给外部调用的类，要在class前面添加关键字export，表示允许被外部引用
export class User{
  name: string
  age: number
  height: number

  constructor() {
    this.name = ''
    this.age = 0
    this.height = 0.0
  }
}