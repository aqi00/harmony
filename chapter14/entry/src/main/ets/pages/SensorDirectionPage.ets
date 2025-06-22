import { sensor } from '@kit.SensorServiceKit';
import { Utils } from '../utils/Utils';

import { CoordinateView } from '../view/CoordinateView';
import { Point } from '../entity/Point';

@Entry
@Component
struct SensorDirectionPage {
  @State message: string = '查看三维空间方向信息';

  @Provide point: Point = new Point(0, 0);
  onPageShow() {
    // 注册方向传感器监听器
    sensor.on(sensor.SensorId.ORIENTATION, (data: sensor.OrientationResponse) => {
      this.point = new Point(Math.round(data.gamma), Math.round(data.beta))
      this.message = `${Utils.getFullDatetime()} 当前x轴角度为${data.beta.toFixed(2)}，y轴角度为${data.gamma.toFixed(2)}，z轴角度为${data.alpha.toFixed(2)}`
    });
  }

  onPageHide() {
    sensor.off(sensor.SensorId.ORIENTATION) // 注销方向传感器监听器
  }

  build() {
    Column() {
      CoordinateView().width('100%').aspectRatio(1)
      Text(this.message).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')

  }
}