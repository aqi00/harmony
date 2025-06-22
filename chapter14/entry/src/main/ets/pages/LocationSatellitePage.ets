import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { Utils } from '../utils/Utils';
import { CompassView } from '../view/CompassView';
import { SatelliteInfo } from '../entity/SatelliteInfo';

@Entry
@Component
struct LocationSatellitePage {
  promptAction = this.getUIContext().getPromptAction();
  @State message: string = ''; // 定位结果
  private sourceArray: string[] = ['未知', '卫星定位',
    '网络定位', '室内高精度定位', '室外高精度定位'];
  @State constellation: string = '';
  private constellationArray: string[] = ['未知', 'GPS', 'SBAS',
    '格洛纳斯', '准天顶', '北斗', '伽利略', 'IRNSS'];
  @Provide direct: number = 999; // 指南针的方向
  @Provide satelliteArray: Array<SatelliteInfo> = new Array<SatelliteInfo>();
  // 订阅GNSS卫星状态信息的回调函数
  gnssStatusCb = (satelliteStatusInfo: geoLocationManager.SatelliteStatusInfo): void => {
    console.info('satelliteStatusChange: ' + JSON.stringify(satelliteStatusInfo));
    let satelliteInfoArray: Array<SatelliteInfo> = []
    if (satelliteStatusInfo) {
      console.info('satelliteStatusInfo.satellitesNumber:' + satelliteStatusInfo.satellitesNumber);
      for (let i=0; i<satelliteStatusInfo.satellitesNumber; i++) {
        let constellation = satelliteStatusInfo.satelliteConstellation
        satelliteInfoArray.push(new SatelliteInfo(
          satelliteStatusInfo.satelliteIds[i], // 编号
          constellation?constellation[i]:0, // 星座
          satelliteStatusInfo.altitudes[i], // 高度角
          satelliteStatusInfo.azimuths[i], // 方位角
          satelliteStatusInfo.carrierFrequencies[i], // 载波频率
          satelliteStatusInfo.carrierToNoiseDensitys[i] // 载波功率
        ))
      }
      this.satelliteArray.length = 0
      this.satelliteArray = satelliteInfoArray.slice()
    }
  }

  onPageShow() {
    geoLocationManager.on('satelliteStatusChange', this.gnssStatusCb) // 订阅卫星状态
  }

  onPageHide() {
    geoLocationManager.off('satelliteStatusChange', this.gnssStatusCb) // 取消订阅
  }

  // 开始定位
  startLocate() {
    this.message = '正在定位，请等待……'
    let locationEnabled = geoLocationManager.isLocationEnabled();
    console.info('locationEnabled='+locationEnabled)
    if (!locationEnabled) {
      this.message = '定位服务不可用'
      return
    }
    geoLocationManager.getCurrentLocation().then((location) => {
      console.info('current location: ' + JSON.stringify(location));
      let locationTime = Utils.getFormatDatetime(location.timeStamp)
      this.message = `定位信息如下：\n` +
        `定位来源为${this.sourceArray[location.sourceType?location.sourceType:0]}\n` +
        `定位时间为${locationTime}\n经度为${location.longitude}\n纬度为${location.latitude}\n` +
        `高度为${Math.round(location.altitude)}米，精度为${Math.round(location.accuracy)}米\n`
    }).catch((error: BusinessError) => {
      console.error('promise, getCurrentLocation: error=' + JSON.stringify(error));
    });
  }

  build() {
    Column() {
      Button('查看全球卫星导航系统').width('100%').fontSize(18)
        .onClick(() => {
          this.promptAction.showToast({message: '请到室外开阔地带以便设备搜寻导航卫星'})
          this.startLocate()  // 开始定位
        })
      Column() {
        CompassView().width('100%').aspectRatio(1).margin({top:5})
        Text(this.message).width('100%').fontSize(18).padding(5)
      }
    }
    .width('100%').height('100%')
  }
}