import { UserInfo } from '../entity/UserInfo'
import { UserDB } from '../entity/UserDB'

@Entry
@Component
struct DatabaseReadPage {
  @State result: string = ''; // 读取结果

  private user_db: UserDB = new UserDB(); // 创建一个用户数据库实例

  build() {
    Column() {
      Button('从数据库读取数据').fontSize(18).width('100%')
        .onClick(() => {
          let userArray = this.user_db.queryAll() // 查询用户数据库中的所有记录
          this.result = '数据库保存的内容如下：\n'
          for (let i=0; i<userArray.length; i++) {
            let user_info = userArray[i]
            this.result = this.result + `第${i+1}条记录信息如下：\n　姓名为${user_info.name}\n　年龄为${user_info.age}\n　身高为${user_info.stature}\n　体重为${user_info.weight}\n　婚否为${user_info.ismarried}\n　更新时间为${user_info.update_time}\n`
            // this.result = this.result + '第' + (i+1) + '条记录信息如下：\n'
            // this.result = this.result + '　姓名为' + user_info.name + '\n'
            // this.result = this.result + '　年龄为' + user_info.age + '\n'
            // this.result = this.result + '　身高为' + user_info.stature + '\n'
            // this.result = this.result + '　体重为' + user_info.stature + '\n'
            // this.result = this.result + '　婚否为' + user_info.ismarried + '\n'
            // this.result = this.result + '　更新时间为' + user_info.update_time + '\n'
          }
          // this.user_db.queryAll((userArray: Array<UserInfo>) => {
          //   this.result = '数据库保存的内容如下：\n'
          //   for (let i=0; i<userArray.length; i++) {
          //     let user_info = userArray[i]
          //     this.result = this.result + '第' + (i+1) + '条记录信息如下：\n'
          //     this.result = this.result + '　姓名为' + user_info.name + '\n'
          //     this.result = this.result + '　年龄为' + user_info.age + '\n'
          //     this.result = this.result + '　身高为' + user_info.stature + '\n'
          //     this.result = this.result + '　体重为' + user_info.weight + '\n'
          //     this.result = this.result + '　婚否为' + user_info.ismarried + '\n'
          //     this.result = this.result + '　更新时间为' + user_info.update_time + '\n'
          //   }
          // })
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').padding(5)
  }
}