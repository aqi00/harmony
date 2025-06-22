import { vibrator } from '@kit.SensorServiceKit';

@Entry
@Component
struct DelayIntervalPage {
  @State result: string = ''; // 振动结果
  private tid: number = -1; // 定时器的编号

  // 开始振动
  vibrate() {
    // 触发马达振动
    vibrator.startVibration({ type: 'time', duration: 500, },
      { id: 0, usage: 'alarm' });
    this.result = `${this.result}设备振动啦\n`
  }

  aboutToDisappear() {
    clearInterval(this.tid) // 清除定时器
  }

  build() {
    Column() {
      Row() {
        Button('延迟3秒后振动').fontSize(18).layoutWeight(1)
          .onClick(() => {
            setTimeout(() => {
              this.vibrate() // 开始振动马达
            }, 3000) // 延迟3000毫秒，即延迟3秒
          })
        Button('每间隔3秒振动').fontSize(18).layoutWeight(1)
          .onClick(() => {
            // 每间隔3000毫秒执行指定逻辑
            this.tid = setInterval((): void => this.vibrate(), 3000)
          })
      }.padding(5)
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}