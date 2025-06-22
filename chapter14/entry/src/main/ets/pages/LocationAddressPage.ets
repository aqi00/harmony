import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Utils } from '../utils/Utils';

@Entry
@Component
struct LocationAddressPage {
  @State message: string = ''; // 定位结果
  private sourceArray: string[] = ['未知', '卫星定位',
    '网络定位', '室内高精度定位', '室外高精度定位'];

  // 获取详细地址
  getAddress(location: geoLocationManager.Location) {
    let geocoderAvailable = geoLocationManager.isGeocoderAvailable();
    console.info('geocoderAvailable='+geocoderAvailable)
    if (!geocoderAvailable) {
      this.message = '逆地理编码服务不可用'
      return
    }
    let reverseGeocodeRequest:geoLocationManager.ReverseGeoCodeRequest =
      {'latitude': location.latitude, 'longitude': location.longitude, 'maxItems': 1};
    geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest)
      .then((data: Array<geoLocationManager.GeoAddress>) => {
        if (data) {
          console.info('getAddressesFromLocation: data=' + JSON.stringify(data));
          let descriptions = data[0].descriptions
          let cityCode = descriptions==undefined ? '' : descriptions[0]
          let adminCode = descriptions==undefined ? '' : descriptions[1]
          this.message = `${this.message}详细地址为${data[0].placeName}\n` +
            `城市代码为${cityCode}，区域代码为${adminCode}`
        }
    }).catch((err: BusinessError) => {
      console.error('getAddressesFromLocation: err=' + JSON.stringify(err));
    })
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
    try {
      let location = geoLocationManager.getLastLocation()
      console.info('last location: ' + JSON.stringify(location));
      geoLocationManager.getCurrentLocation().then((location) => {
        console.info('current location: ' + JSON.stringify(location));
        let locationTime = Utils.getFormatDatetime(location.timeStamp)
        this.message = `定位信息如下：\n` +
          `定位来源为${this.sourceArray[location.sourceType?location.sourceType:0]}\n` +
          `定位时间为${locationTime}\n经度为${location.longitude}\n纬度为${location.latitude}\n` +
          `高度为${Math.round(location.altitude)}米，精度为${Math.round(location.accuracy)}米\n`
        this.getAddress(location) // 获取详细地址
      }).catch((error: BusinessError) => {
        console.error('promise, getCurrentLocation: error=' + JSON.stringify(error));
        this.message = JSON.stringify(error)
      });
    } catch (err) {
      console.error('getLastLocation: error=' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      Button('开始定位并查看地址').width('100%').fontSize(18)
        .onClick(() => {
          this.startLocate()  // 开始定位
        })
      Text(this.message).fontSize(18).width('100%').padding(5)
    }
    .width('100%').height('100%')
  }
}