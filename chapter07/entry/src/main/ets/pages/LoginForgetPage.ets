import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct LoginForgetPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State phone: string = ''; // 手机号码
  @State lastUrl: string = ''; // 上个页面的地址
  @State password1: string = ''; // 新密码
  @State password2: string = ''; // 确认密码
  @State verifyCode: string = ''; // 验证码
  private realVerifyCode: string = ''; // 正确的验证码

  onPageShow() {
    // 获取上个页面传来的参数
    let params = this.router.getParams() as Record<string, Object>;
    this.phone = params?.['phone'] as string
    this.lastUrl = params?.['lastUrl'] as string
  }

  build() {
    Column() {
      Row() {
        Text('输入新密码：').fontSize(18)
        TextInput({ text: $$this.password1, placeholder: '请输入新密码' })
          .type(InputType.NUMBER_PASSWORD).fontSize(18)
          .maxLength(6).layoutWeight(1).inputFilter('[0-9]')
      }.width('100%').height(50).padding(5)
      Row() {
        Text('确认新密码：').fontSize(18)
        TextInput({ text: $$this.password2, placeholder: '请确认新密码' })
          .type(InputType.NUMBER_PASSWORD).fontSize(18)
          .maxLength(6).layoutWeight(1).inputFilter('[0-9]')
      }.width('100%').height(50).padding(5)
      Row() {
        Text('　　验证码：').fontSize(18)
        RelativeContainer() {
          TextInput({ text: $$this.verifyCode, placeholder: '请输入验证码' })
            .width('100%').height('100%').inputFilter('[0-9]')
            .type(InputType.Number).fontSize(18).maxLength(6)
          Button('获取验证码').fontSize(18)
            .alignRules({
              right:{ anchor: '__container__', align: HorizontalAlign.End},
            })
            .onClick(() => {
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
      Button('确　　认').width('100%').fontSize(18).margin({top: 5})
        .onClick(() => {
          if (this.password1.length < 6) {
            this.promptAction.showToast({ message: '请输入正确的新密码' })
            return
          }
          if (this.password1 != this.password2) {
            this.promptAction.showToast({ message: '两次输入的新密码不一致' })
            return
          }
          if (this.verifyCode!=this.realVerifyCode || this.verifyCode.length<6) {
            this.promptAction.showToast({message: '请输入正确的验证码'})
            return
          }
          this.promptAction.showToast({message: '密码修改成功'})
          this.router.back({ // 返回到前一个页面
            url: this.lastUrl,
            params: {
              newPassword: this.password1
            }
          })
        })
    }
    .width('100%').height('100%').padding(5)
  }
}