import { common } from '@kit.AbilityKit';
import { ConfigurationConstant } from '@kit.AbilityKit';

@Entry
@Component
struct ShowModePage {
  @State message: string = '床前明月光，疑是地上霜。\n举头望明月，低头思故乡。';
  // 应用级别的上下文对象
  appContext = this.getUIContext().getHostContext()?.getApplicationContext();
  // HAP级别的上下文对象
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Column() {
      Text(this.message).fontSize(18).fontColor($r('app.color.text_color'))
      Blank().height(100)
      Row() {
        Text('跟随系统').fontSize(18).margin({ right: 10 })
        Radio({ value: 'radio1', group: 'radioGroup' }).checked(true)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.context.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
            }
          })
      }
      Row() {
        Text('浅色模式').fontSize(18).margin({ right: 10 })
        Radio({ value: 'radio2', group: 'radioGroup' }).checked(false)
          .radioStyle({ checkedBackgroundColor: Color.Red })
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.context.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
            }
          })
      }
      Row() {
        Text('深色模式').fontSize(18).margin({ right: 10 })
        Radio({ value: 'radio3', group: 'radioGroup' }).checked(false)
          .radioStyle({ checkedBackgroundColor: Color.Blue })
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.context.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
            }
          })
      }
    }
    .width('100%').backgroundColor($r('app.color.background_color'))
  }
}