import { promptAction } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct EventAddPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext();
  private calendar: calendarManager.Calendar | undefined = undefined;
  private calendarAccount: calendarManager.CalendarAccount = {
    name: 'MyCalendar', // 日历账户的名称
    type: calendarManager.CalendarType.LOCAL // 日历账户的类型
  };

  @State title: string = ''; // 日程标题
  @State description: string = ''; // 日程描述
  private startTime: Date = new Date(); // 日程开始时间
  private endTime: Date = new Date(); // 日程结束时间
  @State startTimeFormat: string = ''; // 开始时间格式
  @State endTimeFormat: string = ''; // 结束时间格式
  @State eventArray: calendarManager.Event[] = []; // 日程列表

  // 获取所有日程
  getEvents(calendar: calendarManager.Calendar) {
    this.calendar = calendar
    this.calendar.getEvents((err: BusinessError, data: calendarManager.Event[]) => {
      if (err) {
        console.error(`Failed to get events. Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info(`Succeeded in getting events, data: ${JSON.stringify(data)}`);
        this.eventArray = data
        console.info('eventArray.length='+this.eventArray.length)
      }
    });
  }

  // 编号为1是默认的日程表，无需创建也不能删除
  // 创建日程表
  createCalendar() {
    let calendarMgr = calendarManager.getCalendarManager(this.context);
    calendarMgr.createCalendar(this.calendarAccount, (err: BusinessError, data: calendarManager.Calendar) => {
      if (err) {
        console.error(`Failed to create calendar. Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info(`Succeeded in creating calendar, data: ${JSON.stringify(data)}`);
        this.getEvents(data)
      }
    });
  }

  onPageShow() {
    let calendarMgr = calendarManager.getCalendarManager(this.context);
    calendarMgr.getCalendar(this.calendarAccount, (err: BusinessError, data:calendarManager.Calendar) => {
      if (err) {
        console.error(`Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
        this.createCalendar()
      } else {
        console.info(`Succeeded in getting calendar, data: ${JSON.stringify(data)}`);
        this.getEvents(data)
      }
    });
    let date = new Date();
    this.endTime = new Date(this.startTime.getTime() + 60 * 60 * 1000)
    this.startTimeFormat = Utils.getFormatDatetime(this.startTime.getTime())
    this.endTimeFormat = Utils.getFormatDatetime(this.endTime.getTime())
  }

  // 添加日程
  addEvent() {
    let event: calendarManager.Event = {
      type: calendarManager.EventType.NORMAL,
      title: this.title,
      description: this.description,
      startTime: this.startTime.getTime(),
      endTime: this.endTime.getTime()
    }
    this.calendar?.addEvent(event, (err: BusinessError, data: number): void => {
      if (err) {
        console.error(`Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info(`Succeeded in adding event, id: ${data}`);
        this.eventArray.push(event)
        this.promptAction.showToast({message: '成功添加日程'})
      }
    });
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
      Button('添加日程').fontSize(18).width('100%')
        .onClick(() => {
          this.addEvent()
        })
      List({ space: 20, initialIndex: 0 }) {
        ForEach(this.eventArray, (item: calendarManager.Event) => {
          ListItem() {
            Row() {
              Text(item.title).height('100%').layoutWeight(3).fontSize(15)
              Text(Utils.getFormatDatetime(item.startTime)+' - '+Utils.getFormatDatetime(item.endTime))
                .height('100%').layoutWeight(5).fontSize(15)
              Text(item.description).height('100%').layoutWeight(3).fontSize(15)
            }.width('100%').height(40)
            .onClick(() => {
              this.router.pushUrl({
                url: 'pages/EventEditPage',
                params: {
                  msg: item,
                }
              })
            })
          }
        })
      }
      .listDirection(Axis.Vertical) // 列表排列方向。默认Vertical表示垂直，为Horizontal表示水平
      .scrollBar(BarState.Off) // 滚动条状态。API 9及以下版本默认BarState.Off，API 10默认BarState.Auto
      .width('100%').padding(5)
    }
    .width('100%').height('100%')
  }
}