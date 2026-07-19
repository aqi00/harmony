export class QuestionInfo {
  id: number // 编号
  question: string // 问题
  answer: string // 答案
  type: number // 类型。0 必需的，不能删除；1 可选的，允许删除

  constructor(question: string, answer: string, type: number) {
    this.id = -1
    this.question = question
    this.answer = answer
    this.type = type
  }
}