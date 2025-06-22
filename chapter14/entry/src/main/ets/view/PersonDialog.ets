import { PersonInfo } from '../entity/PersonInfo'
import { Constants } from '../constant/Constants'

@CustomDialog
export struct PersonDialog {
  @Link person: PersonInfo;
  // @CustomDialog组件必须声明CustomDialogController属性
  private dialogController?: CustomDialogController;
  // 打电话接口，待实例化实现
  dial: (person: PersonInfo) => void = () => { }
  // 去导航接口，待实例化实现
  route: (person: PersonInfo) => void = () => { }

  build() {
    Column() {
      Text(`${this.person?.name}的个人信息`).fontSize(18).margin({ top:20, bottom:10 })
      Row() {
        Column() {
          Text('性别：'+((this.person?.sex==0)?'男':'女'))
            .width('100%').fontSize(18).margin(10)
          Text('爱好：'+this.person?.love)
            .width('100%').fontSize(18).margin(10)
          Text('手机号：'+this.person?.phone)
            .width('100%').fontSize(18).margin(10)
        }.layoutWeight(1).padding({ left:10 }).margin(0)
        Image(Constants.URL_PREFIX + this.person?.face)
          .width(100).height(100).margin({right:20})
          .objectFit(ImageFit.Contain).borderRadius(30)
      }.padding(0).margin(0)
      Column() {
        Text('地址：'+this.person?.address)
          .width('100%').fontSize(18).margin(10)
        Text('发布信息：'+this.person?.info)
          .width('100%').fontSize(18).margin(10)
      }.padding({ left:10 }).margin(0)
      Row() {
        Button((this.person?.sex==0)?'打他电话':'打她电话')
          .layoutWeight(1).fontSize(18).margin(5)
          .backgroundColor(Color.Gray)
          .onClick(() => {
            this.dialogController?.close()
            this.dial(this.person!) // 响应打电话事件
          })
        Button((this.person?.sex==0)?'去他那里':'去她那里')
          .layoutWeight(1).fontSize(18).margin(5)
          .onClick(() => {
            this.dialogController?.close()
            this.route(this.person!) // 响应去导航事件
          })
      }.padding({ left:10, right:10 }).margin({bottom:10})
    }
    .width('100%')
  }
}