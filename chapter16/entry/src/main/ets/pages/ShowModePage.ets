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
    }
    .width('100%').backgroundColor($r('app.color.background_color'))
  }
}