import { sensor } from '@kit.SensorServiceKit';
import { vibrator } from '@kit.SensorServiceKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct SensorAccelertePage {
  @State message: string = '摇一摇看看有什么';

  onPageShow() {
    // 注册加速度传感器监听器
    sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
      if (Math.abs(data.x)>15 || Math.abs(data.y)>15 || Math.abs(data.y)>15) {
        this.message = Utils.getFullDatetime() + ' 我看到你摇一摇啦'
        vibrator.startVibration({ type: 'time', duration: 1000 },
          { id: 0, usage: 'alarm' });
      }
    });
  }

  onPageHide() {
    sensor.off(sensor.SensorId.ACCELEROMETER) // 注销加速度传感器监听器
  }

  build() {
    Column() {
      Text(this.message).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}