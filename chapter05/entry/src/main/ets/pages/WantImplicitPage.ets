import { common } from '@kit.AbilityKit';
import { Want } from '@kit.AbilityKit';

@Entry
@Component
struct WantImplicitPage {

  build() {
    Column() {
      Row() {
        Button('打开浏览器').fontSize(17).layoutWeight(1)
          .onClick(() => {
            let context = this.getUIContext().getHostContext() as common.UIAbilityContext
            let want: Want = {
              action: 'ohos.want.action.viewData', // 查看数据动作
              //entities: ['entity.system.browsable'], // 不用这行也能打开浏览器
              uri: 'https://developer.huawei.com/' // 华为开发者网站
            }
            context.startAbility(want) // 启动意图指定的Ability应用
          })
        Button('打开应用市场').fontSize(17).layoutWeight(1)
          .onClick(() => {
            let context = this.getUIContext().getHostContext() as common.UIAbilityContext
            let want: Want = {
              //action: 'ohos.want.action.appdetail', // 不用这行也能打开应用市场
              // id值可填应用包名或者开头加C的appid，例如com.xxx.xxx（包名）、Cxxx（xxx为appid）等等
              uri: 'store://appgallery.huawei.com/app/detail?id=com.tencent.wechat', // 微信
              //uri: 'store://appgallery.huawei.com/app/detail?id=com.tencent.qq', // QQ正式版待上线
            }
            context.startAbility(want) // 启动意图指定的Ability应用
          })
      }.padding({top: 6, bottom: 6})

    }
    .width('100%').height('100%')
  }
}