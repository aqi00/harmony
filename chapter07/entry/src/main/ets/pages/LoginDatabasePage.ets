import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

import { UserInfo } from '../entity/UserInfo';
import { UserDB } from '../entity/UserDB';

@Entry
@Component
struct LoginDatabasePage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State loginType: number = 0; // 登录类型。0为密码登录，1为验证码登录
  @State phone: string = ''; // 手机号码
  @State password: string = ''; // 密码或验证码
  @State isRemember: boolean = false; // 是否记住密码
  private realPassword: string = '111111'; // 正确的密码
  private realVerifyCode: string = ''; // 正确的验证码

  private user_db: UserDB = new UserDB(); // 创建一个用户数据库实例

  onPageShow() {
    // 获取下个页面返回的参数
    let params = this.router.getParams() as Record<string, Object>;
    if (params) { // 有返回新密码才赋值
      this.realPassword = params?.['newPassword'] as string
    }
  }

  build() {
    Column() {
      Row() {
        Radio({ value: 'radio1', group: 'radioGroup' }).checked(true)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.loginType = 0
              this.password = ''
            }
          })
        Text('密码登录').fontSize(18)
        Blank().height('100%').layoutWeight(1)
        Radio({ value: 'radio2', group: 'radioGroup' }).checked(false)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.loginType = 1
              this.password = ''
              this.isRemember = false
            }
          })
        Text('验证码登录').fontSize(18)
        Blank().height('100%').layoutWeight(1)
      }.width('100%').height(50).padding(5)
      Row() {
        Text('手机号码：').fontSize(18)
        TextInput({ text: $$this.phone, placeholder: '请输入手机号码' })
          .layoutWeight(1).height('100%').inputFilter('[0-9]')
          .type(InputType.Number).fontSize(18).maxLength(11)
      }.width('100%').height(50).padding(5)
      if (this.loginType == 0) {
        Row() {
          Text('登录密码：').fontSize(18)
          RelativeContainer() {
            TextInput({ text: $$this.password, placeholder: '请输入登录密码' })
              .layoutWeight(1).height('100%').inputFilter('[0-9]')
              .type(InputType.NUMBER_PASSWORD).fontSize(18).maxLength(6)
              .onFocus(() => { // 捕捉到焦点获得事件
                if (this.phone.length == 11) { // 查询11位手机号码对应的用户登录信息
                  let user_info = this.user_db.queryByPhone(this.phone)
                  if (user_info.password.length > 0) {
                    this.password = user_info.password
                  }
                }
              })
            Button('忘记密码').fontSize(18)
              .alignRules({
                right:{ anchor: '__container__', align: HorizontalAlign.End},
              })
              .onClick(() => {
                if (this.phone.length < 11) {
                  this.promptAction.showToast({message: '请输入正确的手机号'})
                  return
                }
                this.router.pushUrl({
                  url: 'pages/LoginForgetPage',
                  params: {
                    phone: this.phone,
                    lastUrl: this.router.getState().path + this.router.getState().name
                  }
                })
              })
          }.height('100%').layoutWeight(1)
        }.width('100%').height(50).padding(5)
        Row() {
          Checkbox().select($$this.isRemember)
          Text('记住密码').fontSize(18)
        }.width('100%').height(50).padding(5)
      } else {
        Row() {
          Text('　验证码：').fontSize(18)
          RelativeContainer() {
            TextInput({ text: $$this.password, placeholder: '请输入验证码' })
              .layoutWeight(1).height('100%').inputFilter('[0-9]')
              .type(InputType.Number).fontSize(18).maxLength(6)
            Button('获取验证码').fontSize(18)
              .alignRules({
                right:{ anchor: '__container__', align: HorizontalAlign.End},
              })
              .onClick(() => {
                if (this.phone.length < 11) {
                  this.promptAction.showToast({message: '请输入正确的手机号'})
                  return
                }
                this.realVerifyCode = Math.floor(Math.random() * 1000000) + ''
                let desc = `手机号${this.phone}，本次验证码是${this.realVerifyCode}，请输入验证码`
                this.promptAction.showDialog({
                  title: '请记住验证码',
                  message: desc,
                  buttons: [
                    { text: '好的', color: '#000000' }
                  ]
                })
              })
          }.height('100%').layoutWeight(1)
        }.width('100%').height(50).padding(5)
      }
      Button('登　　录').width('100%').fontSize(18).margin({top: 5})
        .onClick(() => {
          if (this.phone.length < 11) {
            this.promptAction.showToast({message: '请输入正确的手机号'})
            return
          }
          if (this.loginType == 0 && (this.password!=this.realPassword || this.password.length<6)) {
            this.promptAction.showToast({message: '请输入正确的登录密码'})
            return
          }
          if (this.loginType == 1 && (this.password!=this.realVerifyCode || this.password.length<6)) {
            this.promptAction.showToast({message: '请输入正确的验证码'})
            return
          }
          let desc = `您的手机号码是${this.phone}，恭喜你通过登录验证，点击“确定”按钮返回上个页面`
          this.promptAction.showDialog({
            title: '登录成功',
            message: desc,
            buttons: [
              { text: '确定返回', color: '#000000' },
              { text: '我再看看', color: '#000000' },
            ]
          }).then(data => {
            if (data.index == 0) {
              this.router.back() // 返回到前一个页面
            }
          })
          if (this.isRemember) { // 勾选保存密码就要保存登录信息
            let user_info = new UserInfo()
            user_info.phone = this.phone
            user_info.password = this.password
            this.user_db.insert(user_info) // 向用户数据库插入一条记录
          }
        })
    }
    .width('100%').height('100%').padding(5)
  }

}