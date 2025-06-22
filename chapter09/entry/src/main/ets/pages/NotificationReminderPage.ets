import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 注意：因管控限制，三方应用初始的可用提醒数量为0，不能使用代理提醒。
// 需要向华为通过hwpush@huawei.com邮箱向华为侧申请，邮件会在10个工作日内回复（含权益开通结果）
@Entry
@Component
struct NotificationReminderPage {
  promptAction = this.getUIContext().getPromptAction();
  @State title: string = ''; // 通知标题
  @State content: string = ''; // 通知内容
  private reminderId: number = 0; // 提醒编号

  aboutToAppear() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
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
  }

  // 发布代理提醒
  sendReminder() {
    // 倒计时提醒请求ReminderRequestTimer
    let timer: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: 10 // 倒计时的秒数
    }
    // 发布后台代理提醒
    reminderAgentManager.publishReminder(timer)
      .then((reminderId: number) => {
        console.log("promise, reminderId = " + reminderId);
        this.reminderId = reminderId
      }).catch((err: BusinessError) => {
      console.error("promise err code:" + err.code + " message:" + err.message);
    });
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
      Row() {
        Button('发布代理提醒').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.sendReminder() // 发布代理提醒
            this.promptAction.showToast({message: '已发布代理提醒，请前往通知栏查看'})
          })
        Button('取消代理提醒').fontSize(18).layoutWeight(1)
          .onClick(() => {
            reminderAgentManager.cancelReminder(this.reminderId).then(() => {
              console.log("cancelReminder promise");
            }).catch((err: BusinessError) => {
              console.error("promise err code:" + err.code + " message:" + err.message);
            });
            this.promptAction.showToast({message: '已取消代理提醒，请前往通知栏查看'})
          })
      }.padding(5)
    }
    .width('100%').height('100%')
  }
}