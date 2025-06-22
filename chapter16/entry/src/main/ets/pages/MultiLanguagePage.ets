import { i18n } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct MultiLanguagePage {
  @State result: string = ''; // 获取结果

  build() {
    Column() {
      Button('查看系统语言').width('100%').fontSize(18)
        .onClick(() => {
          let context = this.getUIContext().getHostContext() as common.UIAbilityContext
          let resMgr = context.resourceManager
          let languageis = resMgr.getStringSync($r('app.string.languageis').id)
          let language = i18n.System.getSystemLanguage()
          this.result = `${languageis} ${language}`
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}