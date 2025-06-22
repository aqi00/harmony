import { promptAction } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct EventEditPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext();
  private calendar?: calendarManager.Calendar;
  private calendarAccount: calendarManager.CalendarAccount = {
    name: 'MyCalendar',
    type: calendarManager.CalendarType.LOCAL
  };

  private event?: calendarManager.Event; // 日程事件
  @State title: string = ''; // 日程标题
  @State description: string = ''; // 日程描述
  private startTime: Date = new Date(); // 日程开始时间
  private endTime: Date = new Date(); // 日程结束时间
  @State startTimeFormat: string = ''; // 开始时间格式
  @State endTimeFormat: string = ''; // 结束时间格式

  aboutToAppear() {
    let calendarMgr = calendarManager.getCalendarManager(this.context);
    calendarMgr.getCalendar(this.calendarAccount, (err: BusinessError, data:calendarManager.Calendar) => {
      if (err) {
        console.error(`Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info(`Succeeded in getting calendar, data: ${JSON.stringify(data)}`);
        this.calendar = data
      }
    });
  }

  onPageShow() {
    let params = this.router.getParams() as Record<string, Object>;
    this.event = params?.['msg'] as calendarManager.Event
    this.title = this.event.title!
    this.description = this.event.description!
    this.startTime = new Date(this.event.startTime)
    this.endTime = new Date(this.event.endTime)
    this.startTimeFormat = Utils.getFormatDatetime(this.startTime.getTime())
    this.endTimeFormat = Utils.getFormatDatetime(this.endTime.getTime())
  }

  // 删除日程
  deleteEvent() {
    this.calendar?.deleteEvent(this.event?.id, (err: BusinessError) => {
      if (err) {
        console.error(`Failed to delete event. Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info(`Succeeded in deleting event`);
        this.promptAction.showToast({message: '成功删除日程'})
        this.router.back() // 返回到前一个页面
      }
    });
  }

  // 保存日程
  saveEvent() {
    if (this.event) {
      this.event.title = this.title
      this.event.description = this.description
      this.event.startTime = this.startTime.getTime()
      this.event.endTime = this.endTime.getTime()
      this.calendar?.updateEvent(this.event, (err: BusinessError) => {
        if (err) {
          console.error(`Failed to update event. Code: ${err.code}, message: ${err.message}`);
        } else {
          console.info("Succeeded in updating event");
          this.promptAction.showToast({message: '成功保存日程'})
          this.router.back() // 返回到前一个页面
        }
      });
    }
  }

  build() {
    Column() {
      Row() {
        Text('日程标题：').fontSize(18)
        TextInput({ text: $$this.title, placeholder: '请输入日程标题' })
          .type(InputType.Normal).fontSize(18).layoutWeight(3)
      }.padding(5)
      Row() {
        Text('日程描述：').fontSize(18)
        TextInput({ text: $$this.description, placeholder: '请输入日程描述' })
          .type(InputType.Normal).fontSize(18).layoutWeight(3)
      }.padding(5)
      Row() {
        Text('开始时间：').fontSize(18)
        Text(this.startTimeFormat).fontSize(18).layoutWeight(3)
        Button('修改').fontSize(18).onClick(() => {
          TimePickerDialog.show({
            selected: new Date(this.startTime), // 默认的选中时间
            useMilitaryTime: true, // 是否为24小时制
            onAccept: (value: TimePickerResult) => {
              console.info("TimePickerDialog:onAccept()" + value.toString())
              this.startTime.setHours(value.hour, value.minute, 0)
              this.startTimeFormat = Utils.getFormatDatetime(this.startTime.getTime())
            }
          })
        })
      }.padding(5)
      Row() {
        Text('结束时间：').fontSize(18)
        Text(this.endTimeFormat).fontSize(18).layoutWeight(3)
        Button('修改').fontSize(18).onClick(() => {
          TimePickerDialog.show({
            selected: new Date(this.endTime), // 默认的选中时间
            useMilitaryTime: true, // 是否为24小时制
            onAccept: (value: TimePickerResult) => {
              console.info("TimePickerDialog:onAccept()" + value.toString())
              this.endTime.setHours(value.hour, value.minute, 0)
              this.endTimeFormat = Utils.getFormatDatetime(this.endTime.getTime())
            }
          })
        })
      }.padding(5)
      Row() {
        Button('保存日程').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.saveEvent()
          })
        Button('删除日程').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.deleteEvent()
          })
      }.padding(5)
    }
    .width('100%').height('100%')
  }
}