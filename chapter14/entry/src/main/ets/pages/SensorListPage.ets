import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct SensorListPage {
  @State message: string = '当前设备支持的传感器列表如下：';
  @State sensorArray: Array<sensor.Sensor> = []; // 传感器信息列表
  // 编号14、15、262、268、269、277、282、516等传感器枚举有待官方定义
  // 与mate60pro相比，nova12pro缺少：气压计传感器、霍尔传感器、计步器检测传感器，以及编号277的传感器
  private nameMap = new Map([ [1, '加速度传感器'], [2, '陀螺仪传感器'], [5, '环境光传感器'],
    [6, '磁场传感器'], [8, '气压计传感器'], [10, '霍尔传感器'], [12, '接近光传感器'],
    [13, '湿度传感器'], [14, '颜色传感器'], [15, '电磁辐射传感器'], [256, '方向传感器'],
    [257, '重力传感器'], [258, '线性加速度传感器'], [259, '旋转矢量传感器'],
    [260, '环境温度传感器'], [261, '未校准磁场传感器'], [262, ''], [263, '未校准陀螺仪'],
    [264, '大幅度动作传感器'], [265, '计步器检测传感器'], [266, '计步器传感器'],
    [267, ''], [268, ''], [269, ''], [277, ''], [278, '心率传感器'],
    [280, '佩戴检测传感器'], [281, '未校准加速度传感器'], [282, ''], [516, ''] ]);

  // 获取传感器列表
  getSensorList() {
    sensor.getSensorList().then((data: Array<sensor.Sensor>) => {
      data.sort((a, b) => a.sensorId - b.sensorId)
      this.sensorArray.length = 0
      this.sensorArray = data.slice() // 支持的传感器列表
      }).catch((err: BusinessError) => {
      console.error(`Failed to get sensorList. Code: ${err.code}, message: ${err.message}`);
    })
  }

  build() {
    Column() {
      Button('查看支持的传感器列表').width('100%').fontSize(18)
        .onClick(() => {
          this.getSensorList() // 获取传感器列表
        })
      Text(this.message).fontSize(18).width('100%').padding(5)
      List({space: 0}) {
        ForEach(this.sensorArray, (item: sensor.Sensor) => {
          ListItem() {
            Text(`编号${item.sensorId} ${this.nameMap.get(item.sensorId)}：${item.sensorName}`)
              .width('100%').fontSize(18).textAlign(TextAlign.Start)
          }
        })
      }
      .layoutWeight(1).padding({ left:5, right:5 })
    }
    .width('100%').height('100%')
  }
}