import { common } from '@kit.AbilityKit';
import { Want } from '@kit.AbilityKit';

// 联系人信息
interface ModelContactInfo {
  contactsName: string; // 联系人名称
  telephone: string; // 电话号码
}

// 打开系统自带的信息应用
function openMmsPage(context: common.UIAbilityContext) {
  let contactInfo: Array<ModelContactInfo> = [{
    contactsName: 'ZhangSan', // 联系人名称
    telephone: '159XXXX8696' // 联系人号码
  }];
  console.info('contactInfo: '+JSON.stringify(contactInfo))
  let want: Want = {
    bundleName: 'com.ohos.mms', // 信息应用的包名
    abilityName: 'com.ohos.mms.MainAbility', // 信息应用的入口UIAbility
    parameters: { // 待传递的联系人信息
      contactObjects: JSON.stringify(contactInfo),
      pageFlag: 'conversation'
    }
  }
  context.startAbility(want) // 启动意图指定的Ability应用
}

@Entry
@Component
struct WantExplicitPage {

  build() {
    Column() {
      Row() {
        Button('打开应用入口').fontSize(17).layoutWeight(1)
          .onClick(() => {
            let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            //let bundleName = context.abilityInfo.bundleName
            let bundleName = 'com.aqi00.chapter04'
            console.info('bundleName='+bundleName)
            let want: Want = {
              bundleName: bundleName, // 包名
              abilityName: 'EntryAbility' // 入口的UIAbility
            }
            context.startAbility(want) // 启动意图指定的Ability应用
          })
        Button('打开信息应用').fontSize(17).layoutWeight(1)
          .onClick(() => {
            let context = this.getUIContext().getHostContext() as common.UIAbilityContext
            openMmsPage(context) // 打开系统自带的信息应用
          })
      }.padding({top: 6, bottom: 6})

    }
    .width('100%').height('100%')
  }
}