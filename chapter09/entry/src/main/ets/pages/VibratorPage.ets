import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct VibratorPage {
  @State message: string = '请点击按钮观察振动结果'; // 振动控制结果

  build() {
    Column() {
      Row() {
        Button('按照持续时间振动').fontSize(18).layoutWeight(1)
          .onClick(() => {
            vibrator.startVibration(
              { type: 'time', duration: 1000 },
              { id: 0, usage: 'alarm' }).then(() => {
                console.info('Succeed in starting vibration');
                //this.message = Utils.getFullDatetime() + ' 开始按照持续时间振动啦'
                this.message = '开始按照持续时间振动啦'
              }).catch((err: BusinessError) => {
              console.error(`Failed to start vibration. Code: ${err.code}, message: ${err.message}`);
            })
          })
        Button('按照预置效果振动').fontSize(18).layoutWeight(1)
          .onClick(() => {
            vibrator.startVibration(
              { type: 'preset', effectId: 'haptic.clock.timer', count: 1 },
              { id: 0, usage: 'alarm'  }).then(() => {
                console.info('Succeed in starting vibration');
                //this.message = Utils.getFullDatetime() + ' 开始按照预置效果振动啦'
                this.message = '开始按照预置效果振动啦'
              }).catch((err: BusinessError) => {
              console.error(`Failed to start vibration. Code: ${err.code}, message: ${err.message}`);
            })
          })
      }
      Button('停止所有振动').fontSize(18).width('100%').margin(5)
        .onClick(() => {
          // 停止所有模式的马达振动
          vibrator.stopVibration().then(() => {
            console.info('Succeed in stopping vibration');
            //this.message = Utils.getFullDatetime() + ' 立刻停止振动啦'
            this.message = '立刻停止振动啦'
          }).catch((err: BusinessError) => {
            console.error(`Failed to stop vibration. Code: ${err.code}, message: ${err.message}`);
          })
      })
      Text(this.message).fontSize(18).width('100%').padding({left:5})
    }
    .width('100%').height('100%')
  }
}