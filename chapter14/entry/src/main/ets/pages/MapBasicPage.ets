import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MapUtil } from '../utils/MapUtil';

@Entry
@Component
struct MapBasicPage {
  private isFirstLoc: boolean = true; // 是否首次定位
  private mapController?: map.MapComponentController; // 地图组件控制器
  // 地图初始化参数，设置地图中心点坐标及层级
  private target: mapCommon.LatLng = {
    latitude: 39.9181, longitude: 116.3970193
  };
  private cameraPosition: mapCommon.CameraPosition = {
    target: this.target, zoom: 15
  };
  private mapOptions: mapCommon.MapOptions = {
    position: this.cameraPosition,
    mapType: mapCommon.MapType.STANDARD
  };
  // 地图组件的初始化结果回调函数
  callback: AsyncCallback<map.MapComponentController> = (err, mapController) => {
    if (err) {
      console.error('MapComponent: error=' + JSON.stringify(err));
    } else {
      console.info('get mapController');
      this.mapController = mapController
      this.mapController.setMyLocationEnabled(true) // 是否启用“我的位置”图层。默认为false
      this.mapController.setMyLocationControlsEnabled(true) // 是否启用“我的位置”按钮。默认为false
      this.mapController.setZoomControlsEnabled(true) // 是否启用缩放控制器。默认为true
      this.mapController.setZoomGesturesEnabled(true) // 是否启用缩放手势。默认为true
      this.mapController.setCompassControlsEnabled(true) // 是否启用指南针。默认为true
      this.getLocation() // 获取当前位置
    }
  }

  // 显示我的位置
  showMyLocation(location: geoLocationManager.Location) {
    // 注意，不能直接用定位的location，要先把latitude和longitude复制过来，其他字段清零
    let position: geoLocationManager.Location = {
      'latitude': location.latitude, // 纬度
      'longitude': location.longitude, // 经度
      'altitude': 0, // 高度
      'accuracy': 0, // 经度
      'speed': 0, // 速度
      'timeStamp': 0, // 位置时间戳，UTC格式
      'direction': 0, // 方向
      'timeSinceBoot': 0 // 位置时间戳，开机时间格式
    };
    this.mapController?.setMyLocation(position) // 设置用户的位置

    // 转换经纬度坐标
    let truePosition = MapUtil.convertPosition(location.latitude, location.longitude)
    let cameraUpdate = map.newLatLng(truePosition, 15)
    // 以动画方式移动地图相机
    this.mapController?.animateCamera(cameraUpdate, 300) // 动态切换相机视角
  }

  // 获取当前位置
  getLocation() {
    let location = geoLocationManager.getLastLocation()
    console.info('last location: ' + JSON.stringify(location));
    this.showMyLocation(location) // 显示我的位置
    geoLocationManager.getCurrentLocation().then(location => {
      console.info('current location: ' + JSON.stringify(location));
      if (this.isFirstLoc) { // 是首次成功定位
        this.isFirstLoc = false
        this.showMyLocation(location) // 显示我的位置
      }
    }).catch((error: BusinessError) => {
      console.error('promise, getCurrentLocation: error=' + JSON.stringify(error));
    });
  }

  build() {
    Column() {
      Row() {
        Radio({ value: 'radio1', group: 'radioGroup' })
          .checked(true)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              // 设置地图类型。STANDARD表示标准地图
              this.mapController?.setMapType(mapCommon.MapType.STANDARD);
            }
          })
        Text('显示标准地图').fontSize(18)
        Blank().height('100%').layoutWeight(1)
        Radio({ value: 'radio2', group: 'radioGroup' })
          .checked(false)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              // 设置地图类型。TERRAIN表示地形图
              this.mapController?.setMapType(mapCommon.MapType.TERRAIN);
            }
          })
        Text('显示地形图').fontSize(18)
        Blank().height('100%').layoutWeight(1)
        Radio({ value: 'radio3', group: 'radioGroup' })
          .checked(false)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              // 设置地图类型。NONE表示不显示地图
              this.mapController?.setMapType(mapCommon.MapType.NONE);
            }
          })
        Text('显示空白').fontSize(18)
      }.width('100%').height(50).padding(5)
      // 下面调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%').layoutWeight(1)
    }
    .width('100%').height('100%')
  }
}