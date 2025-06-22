import { common } from '@kit.AbilityKit';
import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct CalendarCreatePage {
  context = this.getUIContext().getHostContext();
  @State result: string = '请创建或删除日程表'; // 操作结果
  private calendar: calendarManager.Calendar | undefined = undefined;
  private calendarAccount: calendarManager.CalendarAccount = {
    name: 'MyCalendar', // 日历账户的名称
    type: calendarManager.CalendarType.LOCAL // 日历账户的类型
  };

  // 编号为1是默认的日程表，无需创建也不能删除
  // 创建日程表
  createCalendar() {
    let calendarMgr = calendarManager.getCalendarManager(this.context);
    calendarMgr.createCalendar(this.calendarAccount)
      .then((data: calendarManager.Calendar) => {
        console.info(`Succeeded in creating calendar, data: ${JSON.stringify(data)}`);
        this.calendar = data;
        this.result = `已创建编号是${this.calendar.id}的日程表`
      }).catch((err: BusinessError) => {
      console.error(`Failed to create calendar. Code: ${err.code}, message: ${err.message}`);
    })
  }

  // 删除日程表
  deleteCalendar(calendar: calendarManager.Calendar|undefined) {
    if (calendar) {
      let calendarMgr = calendarManager.getCalendarManager(this.context);
      calendarMgr.deleteCalendar(calendar).then(() => {
        console.info("Succeeded in deleting calendar");
        this.result = `已删除编号是${calendar.id}的日程表`
      }).catch((err: BusinessError) => {
        console.error(`Failed to delete calendar. Code: ${err.code}, message: ${err.message}`);
      })
    }
  }

  // 删除所有日程表
  deleteAllCalendar() {
    let calendarMgr = calendarManager.getCalendarManager(this.context);
    calendarMgr.getAllCalendars((err: BusinessError, data: calendarManager.Calendar[]) => {
      if (err) {
        console.error(`Failed to get all calendars. Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info(`Succeeded in getting all calendars, data -> ${JSON.stringify(data)}`);
        data.forEach((calendar) => {
          console.info(`account -> ${JSON.stringify(calendar)}`);
          this.deleteCalendar(calendar)
          this.result = '已删除所有日程表'
        })
      }
    });
  }

  build() {
    Column() {
      Row() {
        Button('创建日程表').fontSize(17).layoutWeight(1)
          .onClick(() => {
            this.createCalendar() // 创建日程表
          })
        Button('删除日程表').fontSize(17).layoutWeight(1)
          .onClick(() => {
            this.deleteCalendar(this.calendar) // 删除日程表
          })
      }
      // Button('删除所有日程表').width('100%').margin({top: 5})
      //   .fontSize(17)
      //   .onClick(() => {
      //     this.deleteAllCalendar() // 删除所有日程表
      //   })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}