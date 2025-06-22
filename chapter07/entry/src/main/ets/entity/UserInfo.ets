export class UserInfo {
  id: number
  name: string
  age: number
  stature: number
  weight: number
  ismarried: boolean
  update_time: string
  phone: string
  password: string

  constructor() {
    this.id = -1
    this.name = ''
    this.age = 0
    this.stature = 0
    this.weight = 0
    this.ismarried = false
    this.update_time = ''
    this.phone = ''
    this.password = ''
  }

}