import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { MapUtil } from '../utils/MapUtil';

import { navi } from '@kit.MapKit';

@Entry
@Component
struct MapNavigationPage {
  promptAction = this.getUIContext().getPromptAction();
  private isFirstLoc: boolean = true; // 是否首次定位
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
      this.mapEventManager = this.mapController.getEventManager() // 获取地图事件的管理器
      this.mapEventManager.on('mapClick', (position) => {
        console.info('mapClick', `on-mapClick position = ${position.longitude}`);
        this.positionArray.push(position)
        if (this.positionArray.length == 1) {
          this.showPosMarker(position, '起点') // 显示位置标记
        }
        this.queryRoute() // 查询导航路线
      });
      this.getLocation() // 获取当前位置
    }
  }

  aboutToDisappear() {
    this.mapEventManager?.off('mapClick')
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
    let cameraUpdate = map.newLatLng(truePosition, 14)
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

  private routeType: number = 0; // 导航类型
  private positionArray: mapCommon.LatLng[] = []; // 路线途径点数组

  build() {
    Column() {
      Row() {
        Radio({ value: 'radio1', group: 'radioGroup' })
          .checked(true)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.routeType = 0 // 导航类型为步行
              this.queryRoute() // 查询导航路线
            }
          })
        Text('步行导航').fontSize(18)
        Blank().height('100%').layoutWeight(1)
        Radio({ value: 'radio2', group: 'radioGroup' })
          .checked(false)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.routeType = 1 // 导航类型为行车
              this.queryRoute() // 查询导航路线
            }
          })
        Text('行车导航').fontSize(18)
        Blank().height('100%').layoutWeight(1)
      }.width('100%').height(50).padding(5)
      // 调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%').layoutWeight(1)
    }
    .width('100%').height('100%')
  }

  // 查询导航路线
  queryRoute() {
    let len = this.positionArray.length
    if (len >= 2) {
      this.mapController?.clear() // 移除地图上所有的圆、标记、折线等覆盖物
      let beginPos = this.positionArray[0]
      let endPos = this.positionArray[len-1]
      this.showPosMarker(beginPos, '起点') // 显示位置标记
      this.showPosMarker(endPos, '终点') // 显示位置标记
      if (this.routeType == 0) {
        this.getWalkingRoute(beginPos, endPos) // 获取步行导航
      } else {
        this.getDrivingRoute(beginPos, endPos) // 获取行车导航
      }
    }
  }

  // 获取步行导航
  getWalkingRoute(beginPos: mapCommon.LatLng, endPos: mapCommon.LatLng) {
    console.info('begin getWalkingRoute');
    let params: navi.RouteParams = {
      origins: [beginPos], // 起点
      destination: endPos, // 终点
      language: 'zh_CN' // 描述文字的语种。目前只支持中文zh_CN和英文en
    };
    navi.getWalkingRoutes(params).then(value => {
      console.info('Succeeded in getting walking routes.');
      this.showRoute(value.routes) // 显示导航路线
    }).catch((error: BusinessError) => {
        console.error('promise, getWalkingRoutes: error=' + JSON.stringify(error));
      });
  }

  // 获取行车导航
  getDrivingRoute(beginPos: mapCommon.LatLng, endPos: mapCommon.LatLng) {
    console.info('begin getDrivingRoute');
    let params: navi.DrivingRouteParams = {
      origins: [beginPos], // 起点
      destination: endPos, // 终点
      language: 'zh_CN' // 描述文字的语种。目前只支持中文zh_CN和英文en
    };
    navi.getDrivingRoutes(params).then(value => {
      console.info('Succeeded in getting driving routes.');
      this.showRoute(value.routes) // 显示导航路线
    }).catch((error: BusinessError) => {
        console.error('promise, getDrivingRoutes: error=' + JSON.stringify(error));
      });
  }

  // 显示导航路线
  showRoute(routes: Array<navi.Route>) {
    if (routes==undefined || routes.length==0) {
      this.promptAction.showToast({message: '未找到导航路径'})
      return
    }
    let lines = routes[0].overviewPolyline
    if (lines==undefined || lines.length==0) {
      this.promptAction.showToast({message: '未找到路径详情'})
      return
    }
    let options: mapCommon.MapPolylineOptions = {
      points: lines, // 折线的一组顶点坐标
      color: 0xff0000ff, // 折线的颜色。注意，这里不能用Color.Blue
      width: 20, // 折线的宽度
    }
    console.warn('addPolyline: ' + JSON.stringify(options))
    this.mapController?.addPolyline(options) // 在地图上添加折线
  }

  // 显示位置标记
  showPosMarker(position: mapCommon.LatLng, desc: string) {
    // 初始化marker（标记）参数
    let markerOptions: mapCommon.MarkerOptions = {
      position: position, // 位置坐标
      clickable: true, // 是否允许点击
      title: '', // 信息窗口的标题
      snippet: desc, // 信息窗口的副标题
      icon: $r('app.media.icon_geo'), // 标记图标
      draggable: false // 是否允许拖动
    };
    this.mapController?.addMarker(markerOptions) // 添加指定位置的标记图标
  }

}