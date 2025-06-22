import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { MapUtil } from '../utils/MapUtil';

@Entry
@Component
struct ChooseLocationPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  private isFirstLoc: boolean = true; // 是否首次定位
  private myPos?: mapCommon.LatLng; // 位置坐标
  private address?: string; // 详细地址

  private mapController?: map.MapComponentController; // 地图组件控制器
  private mapEventManager?: map.MapEventManager; // 地图事件管理器
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
      this.registerClickEvent(this.mapController) // 注册点击事件
      this.getLocation() // 获取当前位置
    }
  }

  // 注册点击事件
  registerClickEvent(mapController: map.MapComponentController) {
    this.mapEventManager = mapController.getEventManager() // 获取地图事件的管理器
    this.mapEventManager.on('mapClick', (position) => {
      console.info('mapClick', `on-mapClick position = ${position.latitude}, ${position.longitude}`);
      this.onMapClick(position) // 触发地图点击事件
    });
    this.mapEventManager.on('markerDragEnd', (marker: map.Marker) => {
      console.info('markerDragEnd', `on-markerDragEnd position = ${marker.getPosition().latitude}, ${marker.getPosition().longitude}`);
      this.onMapClick(marker.getPosition()) // 触发地图点击事件
    });
  }

  aboutToDisappear() {
    this.mapEventManager?.off('mapClick')
    this.mapEventManager?.off('markerDragEnd')
  }

  // 触发地图点击事件
  onMapClick(pos: mapCommon.LatLng) {
    let cameraUpdate = map.newLatLng(pos, 14)
    // 以动画方式移动地图相机
    this.mapController?.animateCamera(cameraUpdate, 300) // 动态切换相机视角
    this.myPos = pos
    this.mapController?.clear() // 移除地图上所有的圆、标记、折线等覆盖物
    this.showPosMarker(pos, this.address!) // 显示位置标记
  }

  // 显示我的位置
  showMyLocation(pos: mapCommon.LatLng) {
    this.getAddress(pos) // 获取详细地址
    // 注意，不能直接用定位的location，要先把latitude和longitude复制过来，其他字段清零
    let position: geoLocationManager.Location = {
      'latitude': pos.latitude, // 纬度
      'longitude': pos.longitude, // 经度
      'altitude': 0, // 高度
      'accuracy': 0, // 经度
      'speed': 0, // 速度
      'timeStamp': 0, // 位置时间戳，UTC格式
      'direction': 0, // 方向
      'timeSinceBoot': 0 // 位置时间戳，开机时间格式
    };
    this.mapController?.setMyLocation(position) // 设置用户的位置

    // 转换经纬度坐标
    let truePosition = MapUtil.convertPosition(pos.latitude, pos.longitude)
    let cameraUpdate = map.newLatLng(truePosition, 14)
    // 以动画方式移动地图相机
    this.mapController?.animateCamera(cameraUpdate, 300) // 动态切换相机视角
    this.myPos = truePosition
  }

  // 获取当前位置
  getLocation() {
    let location = geoLocationManager.getLastLocation()
    console.warn('last location: ' + JSON.stringify(location));
    this.showMyLocation(location) // 显示我的位置
    geoLocationManager.getCurrentLocation().then(location => {
      console.warn('current location: ' + JSON.stringify(location));
      if (this.isFirstLoc) { // 是首次成功定位
        this.isFirstLoc = false
        this.showMyLocation(location) // 显示我的位置
      }
    }).catch((error: BusinessError) => {
      console.error('promise, getCurrentLocation: error=' + JSON.stringify(error));
    });
  }

  // 获取详细地址
  getAddress(pos: mapCommon.LatLng) {
    let reverseGeocodeRequest:geoLocationManager.ReverseGeoCodeRequest =
      {'latitude': pos.latitude, 'longitude': pos.longitude, 'maxItems': 1};
    geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest)
      .then((data: Array<geoLocationManager.GeoAddress>) => {
        if (data) {
          console.info('getAddressesFromLocation: data=' + JSON.stringify(data));
          this.address = data[0].placeName
          let truePosition = MapUtil.convertPosition(pos.latitude, pos.longitude)
          this.showPosMarker(truePosition, this.address!) // 显示位置标记
        }
      }).catch((err: BusinessError) => {
      console.error('getAddressesFromLocation: err=' + JSON.stringify(err));
    })
  }

  build() {
    Column() {
      // 调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%').layoutWeight(1)
      Row() {
        Button('下一步').width('100%').fontSize(18)
          .onClick(() => {
            if (this.myPos) {
              this.router.pushUrl({
                url: 'nearby/InfoEditPage',
                params: {
                  latitude: this.myPos.latitude,
                  longitude: this.myPos.longitude,
                  address: this.address
                }
              })
            } else {
              this.promptAction.showToast({message: '请先选择您的常住地点'})
            }
          })
      }
      .width('100%').padding(5)
    }
    .width('100%').height('100%')
  }

  // 显示位置标记
  showPosMarker(position: mapCommon.LatLng, desc: string) {
    // 初始化marker（标记）参数
    let markerOptions: mapCommon.MarkerOptions = {
      position: position, // 位置坐标
      clickable: true, // 是否允许点击
      title: '', // 信息窗口的标题
      snippet: desc, // 信息窗口的副标题
      icon: $r('app.media.icon_current'), // 标记图标
      draggable: true // 是否允许拖动
    };
    this.mapController?.addMarker(markerOptions) // 添加指定位置的标记图标
  }

}