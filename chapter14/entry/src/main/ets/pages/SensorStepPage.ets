import { sensor } from '@kit.SensorServiceKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct SensorStepPage {
  @State message: string = '走一走看看有什么';
  @State scalar: number = 0; // 步伐动作。为1表示发生步伐动作，为0表示未发生
  @State steps: number = 0; // 总步数

  onPageShow() {
    try {
      // 注册计步检测器的监听器
      sensor.on(sensor.SensorId.PEDOMETER_DETECTION, (data: sensor.PedometerDetectionResponse) => {
        this.scalar = data.scalar // 为1代表发生行走动作，为0代表未发生行走动作
        this.message = `${Utils.getFullDatetime()} 您当前${this.scalar==1?'有':'无'}步伐，总计数为${this.steps}步`
      });
      // 注册步行计数器的监听器
      sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
        this.steps = data.steps // 用户的行走步数
        this.message = `${Utils.getFullDatetime()} 您当前${this.scalar==1?'有':'无'}步伐，总计数为${this.steps}步`
      });
    } catch (err) {
      console.error(`PEDOMETER_DETECTION on failed, code is ${err.code},message is ${err.message}`);
      this.message = '未找到计步检测器'
    }
  }

  onPageHide() {
    try {
      sensor.off(sensor.SensorId.PEDOMETER_DETECTION) // 注销计步检测器的监听器
      sensor.off(sensor.SensorId.PEDOMETER) // 注销步行计数器的监听器
    } catch (err) {
      console.error(`PEDOMETER_DETECTION off failed, code is ${err.code},message is ${err.message}`);
    }
  }

  build() {
    Column() {
      Text(this.message).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}