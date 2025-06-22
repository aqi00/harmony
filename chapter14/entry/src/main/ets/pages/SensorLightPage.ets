import { sensor } from '@kit.SensorServiceKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct SensorLightPage {
  @State message: string = '遮住前置摄像头看看光线变化了没有';

  onPageShow() {
    // 注册光线传感器监听器
    sensor.on(sensor.SensorId.AMBIENT_LIGHT, (data: sensor.LightResponse) => {
      this.message = `${Utils.getFullDatetime()} 当前光强为${data.intensity.toFixed(1)}，色温为${data.colorTemperature}`
    });
  }

  onPageHide() {
    sensor.off(sensor.SensorId.AMBIENT_LIGHT) // 注销光线传感器监听器
  }

  build() {
    Column() {
      Text(this.message).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}