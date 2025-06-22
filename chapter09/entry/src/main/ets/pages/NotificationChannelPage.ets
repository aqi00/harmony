import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct NotificationChannelPage {
  promptAction = this.getUIContext().getPromptAction();
  @State title: string = ''; // 通知标题
  @State content: string = ''; // 通知内容
  private slotNameArray: Array<SelectOption> = [ { value: '未知类型' },
    { value: '社交类型' }, { value: '服务类型' }, { value: '内容类型' },
    { value: '实况视图' }, { value: '客户服务' }, { value: '其他类型' } ];
  // 注意：
  // 1、横幅通知需要到“设置-应用”处手动开启
  // 2、app默认不区分渠道，必须在代码中另外调用addSlot
  // 3、setBadgeNumber的第一个参数不能直接填this.count
  private slotTypeArray: Array<number> = [
    notificationManager.SlotType.UNKNOWN_TYPE,
    notificationManager.SlotType.SOCIAL_COMMUNICATION,
    notificationManager.SlotType.SERVICE_INFORMATION,
    notificationManager.SlotType.CONTENT_INFORMATION,
    notificationManager.SlotType.LIVE_VIEW,
    notificationManager.SlotType.CUSTOMER_SERVICE,
    notificationManager.SlotType.OTHER_TYPES
  ];
  @State current: number = 0; // 当前的渠道序号
  private slotType = this.slotTypeArray[this.current]; // 当前的渠道类型

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
  }

  // 发送消息通知
  sendNotification() {
    this.slotType = this.slotTypeArray[this.current]
    notificationManager.addSlot(this.slotType,  (err: BusinessError): void => {
      if (err) {
        console.error(`addSlot failed, code is ${err.code}, message is ${err.message}`);
      } else {
        console.info('addSlot success');
      }
    });
    // notificationManager.removeSlot(this.slotType) // 移除指定渠道
    // notificationManager.removeAllSlots() // 移除所有渠道
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
      notificationSlotType: this.slotType // 渠道类型
    };
    // 发布消息通知
    notificationManager.publish(notificationRequest, (err: BusinessError): void => {
      if (err) {
        console.error(`publish failed, code is ${err.code}, message is ${err.message}`);
      } else {
        console.info('publish success');
      }
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
        Text('渠道类型：').fontSize(18)
        Select(this.slotNameArray).font({ size: 18 }).layoutWeight(3)
          .selected($$this.current)
          .value(this.slotNameArray[this.current].value)
      }.padding(5)
      Button('发送渠道消息').fontSize(18).width('100%')
        .onClick(() => {
          this.sendNotification() // 发布消息通知
          this.promptAction.showToast({message: '已发送渠道消息，请前往通知栏查看'})
        })
    }
    .width('100%').height('100%')
  }
}