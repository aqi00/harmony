@Entry
@Component
struct TextInputPage {
  @State user_name: string = ''; // 用户名
  @State phone: string = ''; // 手机号
  @State text_password: string = ''; // 文本密码
  @State number_password: string = ''; // 数字密码
  @State result: string = '这里显示提交结果'; // 结果文本

  build() {
    Column() {
      Row() {
        Text('用户名：').fontSize(18)
        TextInput({ text: this.user_name, placeholder: '请输入用户名' })
          .layoutWeight(1).height(40)
          .fontSize(18).fontColor(Color.Black)
          .placeholderColor(Color.Grey) // 提示文本颜色
          .placeholderFont({ size: 18, weight: 400 }) // 提示文本字号
          .type(InputType.Normal) // 输入文本类型。Normal表示普通文本
          .caretColor(Color.Blue) // 光标颜色
          .inputFilter('[a-zA-Z0-9]') // 输入过滤器
          .onChange((value: string) => {
            this.user_name = value
          })
      }.margin(5)
      // Row() {
      //   Text('手机号：').fontSize(18)
      //   TextInput({ text: this.phone, placeholder: '请输入手机号' })
      //     .layoutWeight(1).height(40)
      //     .fontSize(18).fontColor(Color.Black)
      //     .placeholderColor(Color.Grey) // 提示文本颜色
      //     .placeholderFont({ size: 18, weight: 400 }) // 提示文本字号
      //     .type(InputType.Number) // 输入文本类型。Number表示纯数字
      //     .caretColor(Color.Blue) // 光标颜色
      //     .maxLength(11) // 最大字符长度
      //     .inputFilter('[0-9]') // 输入过滤器
      //     .onChange((value: string) => {
      //       this.phone = value
      //     })
      // }.margin(5)
      // Row() {
      //   Text('文本密码：').fontSize(18)
      //   TextInput({ text: this.text_password, placeholder: '请输入密码' })
      //     .layoutWeight(1).height(40)
      //     .fontSize(18).fontColor(Color.Black)
      //     .placeholderColor(Color.Grey) // 提示文本颜色
      //     .placeholderFont({ size: 18, weight: 400 }) // 提示文本字号
      //     .type(InputType.Password) // 输入文本类型。Password表示文本密码
      //     .caretColor(Color.Blue) // 光标颜色
      //     .showPasswordIcon(true) // 是否显示密码图标（睁眼表示显示明文，闭眼表示显示密文）
      //     .maxLength(8) // 最大字符长度
      //     .inputFilter('[a-zA-Z0-9~!@#$%^&*()_+-=]') // 输入过滤器
      //     .onChange((value: string) => {
      //       this.text_password = value
      //     })
      // }.margin(5)
      Row() {
        Text('数字密码：').fontSize(18)
        TextInput({ text: this.number_password, placeholder: '请输入密码' })
          .layoutWeight(1).height(40)
          .fontSize(18).fontColor(Color.Black)
          .placeholderColor(Color.Grey) // 提示文本颜色
          .placeholderFont({ size: 18, weight: 400 }) // 提示文本字号
          .type(InputType.NUMBER_PASSWORD) // 输入文本类型。NUMBER_PASSWORD表示数字密码
          .caretColor(Color.Blue) // 光标颜色
          .showPasswordIcon(true) // 是否显示密码图标（睁眼表示显示明文，闭眼表示显示密文）
          .maxLength(8) // 最大字符长度
          .inputFilter('[0-9]') // 输入过滤器
          .onChange((value: string) => {
            this.number_password = value
          })
      }.margin(5)
      Button('提交').width('100%').margin(5).fontSize(18)
        .onClick(() => {
          //this.result = '您输入的用户名为'+this.user_name+'，手机号为'+this.phone+'，文本密码为'+this.text_password+'，数字密码为'+this.number_password
          this.result = '您输入的用户名为'+this.user_name+'，数字密码为'+this.number_password
        })
      Text(this.result).width('100%').padding(5).fontSize(18)
    }
    .width('100%')
  }
}