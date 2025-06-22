import { PersonInfo } from './PersonInfo'

export interface QueryResponse {
  code: string // 结果代码
  desc: string // 结果描述
  personList: PersonInfo[] // 人员信息列表
}