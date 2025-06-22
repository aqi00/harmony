import { backgroundTaskManager } from '@kit.BackgroundTasksKit';

@Entry
@Component
struct ShortTaskPage {
  private requestId: number = 0; // 短时任务的请求编号
  private delayTime: number = 0; // 本次申请短时任务的剩余时间

  // 申请短时任务
  startShortTask() {
    let myReason = '复制大文件';   // 申请原因。每调用一次申请接口就会有一个新id，短时任务的数量会增加一个
    let delayInfo = backgroundTaskManager.requestSuspendDelay(myReason, () => {
      console.info('suspend delay task will timeout');
      // 短时任务即将超时，这里可执行一些清理和标注工作，并取消短时任务
      this.stopShortTask() // 取消短时任务
    })
    this.requestId = delayInfo.requestId; // 短时任务的请求编号
    this.delayTime = delayInfo.actualDelayTime; // 实际的剩余时间
  }

  // 取消短时任务
  stopShortTask() {
    backgroundTaskManager.cancelSuspendDelay(this.requestId) // 取消短时任务
  }

  build() {
    Column() {
      Button('申请短时任务').fontSize(18).width('100%').margin({ top: 5 })
        .onClick(() => {
          this.startShortTask() // 通过按钮申请短时任务
          // 下面执行短时任务逻辑，比如开始复制大文件
        })
      Button('取消短时任务').fontSize(18).width('100%').margin({ top: 5 })
        .onClick(() => {
          // 此处结束短时任务，比如中断复制大文件
          this.stopShortTask() // 取消短时任务
        })
    }
    .width('100%').height('100%')
  }
}