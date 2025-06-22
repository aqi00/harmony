@Entry
@Component
struct ChooseTooglePage {
  @State message: string = '请点击某个开关项';

  build() {
    Column() {
      Text(this.message).fontSize(18).padding(5)
      Row() {
        Text('开关类型').fontSize(18).margin({ right: 10 })
        Toggle({ type: ToggleType.Switch, isOn: false })
          .selectedColor(Color.Blue) // 组件打开状态的背景颜色
          .switchPointColor(Color.White) // 圆形滑块颜色
          .onChange((isOn: boolean) => {
            this.message = `您${isOn?'打开':'关闭'}了默认开关`
          })
      }
      Row() {
        Text('勾选框类型').fontSize(18).margin({ right: 10 })
        Toggle({ type: ToggleType.Checkbox, isOn: false })
          .onChange((isOn: boolean) => {
            this.message = `您${isOn?'勾选':'取消勾选'}了勾选框`
          })
      }
      Row() {
        Text('按钮类型').fontSize(18).margin({ right: 10 })
        Toggle({ type: ToggleType.Button, isOn: false })
          .width(150).height(30)
          .onChange((isOn: boolean) => {
            this.message = `您${isOn?'打开':'关闭'}了按钮开关`
          })
      }
    }.width('100%')
  }
}