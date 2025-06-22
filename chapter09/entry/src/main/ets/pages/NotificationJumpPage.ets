import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';

@Entry
@Component
struct NotificationJumpPage {
  promptAction = this.getUIContext().getPromptAction();
  @State title: string = ''; // 通知标题
  @State content: string = ''; // 通知内容
  private wantAgentObj?: WantAgent; // 应用的行为意图

  aboutToAppear() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext
    let notifyEnable = notificationManager.isNotificationEnabledSync()
    if (!notifyEnable) {
      // 开启通知功能
      notificationManager.requestEnableNotification(context, (err: BusinessError): void => {
        if (err) {
          console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
        } else {
          console.info('requestEnableNotification success');
        }
      })
    }

    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{
          bundleName: context.abilityInfo.bundleName, // 包名
          abilityName: 'Chapter08Ability', // Ability名称
        }],
      // 点击通知后的动作类型
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0, // 请求代码
      // 点击通知后的动作执行属性
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }
    wantAgent.getWantAgent(wantAgentInfo) // 获取应用的行为意图
      .then((wantAgentObj: WantAgent) => {
        console.info('getWantAgent Callback success')
        this.wantAgentObj = wantAgentObj // 保存应用的行为意图
      }).catch((err: BusinessError) => {
      console.error('getWantAgent Callback err:' + JSON.stringify(err))
    })
  }

  // 发送消息通知
  sendNotification() {
    // 通知请求内容
    let notificationRequest: notificationManager.NotificationRequest = {
      id: 1, // 通知编号
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: this.title, // 通知标题
          text: this.content // 通知内容
        }
      },
      wantAgent: this.wantAgentObj // 应用的行为意图
    };
    // 发布消息通知
    notificationManager.publish(notificationRequest, (err: BusinessError): void => {
      if (err) {
        console.error(`publish failed, code is ${err.code}, message is ${err.message}`);
      } else {
        console.info('publish success');
      }
    });
    // notificationManager.cancel(1) // 清除指定编号的通知
    // notificationManager.cancelAll() // 清除本应用的所有通知
  }

  build() {
    Column() {
      Row() {
        Text('消息标题：').fontSize(18)
        TextInput({ text: $$this.title, placeholder: '请输入消息标题' })
          .type(InputType.Normal).fontSize(18).layoutWeight(3)
      }.padding(5)
      Row() {
        Text('消息内容：').fontSize(18)
        TextInput({ text: $$this.content, placeholder: '请输入消息内容' })
          .type(InputType.Normal).fontSize(18).layoutWeight(3)
      }.padding(5)
      Button('发送跳转消息').fontSize(18).width('100%')
        .onClick(() => {
          this.sendNotification() // 发布消息通知
          this.promptAction.showToast({message: '已发送跳转消息，请前往通知栏查看'})
        })
    }
    .width('100%').height('100%')
  }
}