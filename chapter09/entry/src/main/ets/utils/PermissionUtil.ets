import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit'
import { GlobalThis } from '../utils/GlobalThis';

export class PermissionUtil {

  private static requestAgain(context: common.UIAbilityContext, permissions: Array<Permissions>, index:number) {
    if (index >= permissions.length) {
      return
    }
    let permission = permissions[index++]
    console.info('requestAgain: ' + permission);
    let atManager = abilityAccessCtrl.createAtManager()
    // requestPermissionOnSetting再次请求的权限数组必须为同一个权限组，否则会报错12100001
    atManager.requestPermissionOnSetting(context, [permission]).then((data: Array<abilityAccessCtrl.GrantStatus>) => {
      console.info(permission + ' status:' + JSON.stringify(data));
      PermissionUtil.requestAgain(context, permissions, index)
    }).catch((err: BusinessError) => {
      console.error('err:' + JSON.stringify(err));
    });
  }

  private static reconfirmPermissions(context: common.UIAbilityContext, permissions: Array<Permissions>) {
    let atManager = abilityAccessCtrl.createAtManager()
    let forbidPermissions: Array<Permissions> = []
    let responseCount = 0
    let tokenId = context.applicationInfo.accessTokenId
    for (let permission of permissions) {
      // 校验应用是否授予了指定权限
      atManager.checkAccessToken(tokenId, permission).then((status: abilityAccessCtrl.GrantStatus) => {
        console.info(`checkAccessToken success, ${permission} status: ${JSON.stringify(status)}`);
        if (status == abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
          forbidPermissions.push(permission)
        }
        responseCount++
        if (responseCount >= permissions.length) {
          console.info('forbidPermissions.length:' + forbidPermissions.length);
          if (forbidPermissions.length > 0) {
            PermissionUtil.requestAgain(context, forbidPermissions, 0)
          }
        }
      }).catch((err: BusinessError) => {
        console.error(`checkAccessToken fail, err->${JSON.stringify(err)}`);
      });
    }
  }

  public static checkPermissions(context: common.UIAbilityContext, permissions: Array<Permissions>, forbidHint: string) {
    // PersistentStorage的持久化操作需要在UI实例成功初始化后调用（即loadContent回调），早于该时机调用会导致持久化失败。
    PersistentStorage.persistProp('needRequestAgain', false);
    let atManager = abilityAccessCtrl.createAtManager()
    try {
      // 请求拉起权限设置弹框
      atManager.requestPermissionsFromUser(context, permissions).then((data) => {
        let needRequestAgain = AppStorage.get('needRequestAgain') as boolean
        console.info(`read needRequestAgain: ${needRequestAgain}`)
        // 这里可以把常用参数保存到应用存储中
        // AppStorage.setOrCreate('filePath', this.context.filesDir)
        // AppStorage.setOrCreate('context', this.context)
        console.info(`request permissions from user result: ${JSON.stringify(data)}`)
        for (let result of data.authResults) {
          if (result == abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
            if (needRequestAgain) { // 需要再次请求授权
              PermissionUtil.reconfirmPermissions(context, permissions)
            } else {
              needRequestAgain = true
              let ui_context = GlobalThis.getInstance().getUIContext('ui_context')
              ui_context.getPromptAction().showToast({message: forbidHint})
            }
            break
          }
        }
        console.info(`write needRequestAgain: ${needRequestAgain}`)
        AppStorage.setOrCreate('needRequestAgain', needRequestAgain)
      }).catch((err: Error) => {
        console.error(`request permissions from user err: ${JSON.stringify(err)}`)
      })
    } catch (err) {
      console.error(`request permissions from user  catch err->${JSON.stringify(err)}`);
    }
  }

}