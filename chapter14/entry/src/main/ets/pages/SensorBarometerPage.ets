import { sensor } from '@kit.SensorServiceKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct SensorBarometerPage {
  @State message: string = '检测气压强度';

  onPageShow() {
    try {
      // 注册气压计传感器监听器
      sensor.on(sensor.SensorId.BAROMETER, (data: sensor.BarometerResponse) => {
        this.message = `${Utils.getFullDatetime()} 当前气压为${data.pressure.toFixed(2)}百帕`
      });
    } catch (err) {
      console.error(`BAROMETER on failed, code is ${err.code},message is ${err.message}`);
      this.message = '未找到气压计传感器'
    }
  }

  onPageHide() {
    try {
      sensor.off(sensor.SensorId.BAROMETER) // 注销气压计传感器监听器
    } catch (err) {
      console.error(`BAROMETER off failed, code is ${err.code},message is ${err.message}`);
    }
  }

  build() {
    Column() {
      Text(this.message).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}