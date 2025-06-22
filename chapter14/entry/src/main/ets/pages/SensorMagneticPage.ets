import { sensor } from '@kit.SensorServiceKit';
import { Utils } from '../utils/Utils';
import { CompassView } from '../view/CompassView';
import { SatelliteInfo } from '../entity/SatelliteInfo';

@Entry
@Component
struct SensorMagneticPage {
  @State message: string = '转一转看看指南了没有';
  @State threePos: object = new Object({ x: 0, y: 0, z: 0 }); // 三维坐标
  @Provide direct: number = 999; // 方向角度
  @Provide satelliteArray: Array<SatelliteInfo> = new Array<SatelliteInfo>()

  onPageShow() {
    // 注册磁场传感器监听器
    sensor.on(sensor.SensorId.MAGNETIC_FIELD, (data: sensor.MagneticFieldResponse) => {
      this.threePos['x'] = data.x
      this.threePos['y'] = data.y
      let radian = Math.atan2(this.threePos['x'], this.threePos['y']) // 弧度
      this.direct = radian * 180 / Math.PI // 角度
      let offset = 180 - Math.abs(this.direct)
      this.message = `${Utils.getFullDatetime()} 当前与正南的夹角为${Math.round(offset)}`
    });
  }

  onPageHide() {
    sensor.off(sensor.SensorId.MAGNETIC_FIELD) // 注销磁场传感器监听器
  }

  build() {
    Column() {
      CompassView().width('100%').aspectRatio(1)
      Text(this.message).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}