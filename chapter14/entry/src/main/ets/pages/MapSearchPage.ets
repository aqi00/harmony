import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { MapUtil } from '../utils/MapUtil';

import { site } from '@kit.MapKit';

@Entry
@Component
struct MapSearchPage {
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext() as common.Context;
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
    this.myLocation = location
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

  @State middleText: string = '市内找';
  @State cityName: string = ''; // 城市名称
  @State index: number = 0; // 在城市搜索还是在周边搜索
  @State searchText: string = ''; // 待搜索的地点名称
  private typeArray: SelectOption[] = [{ value: '搜城市' }, { value: '搜周边' }];
  private myLocation?: geoLocationManager.Location; // 我的位置
  private pageIndex: number = 1; // 搜索结果页面序号
  private cityCodeMap = new Map<string, string>(); // 城市代码映射

  aboutToAppear() {
    try {
      // 从资源文件city_code.txt中加载城市代码映射
      let uint8Array = this.context.resourceManager.getRawFileContentSync('city_code.txt');
      const decoder = util.TextDecoder.create('utf-8');
      const str = decoder.decodeToString(uint8Array);
      let labelArray = str.split('\n')
      console.info('labelArray.length='+labelArray.length)
      for (let label of labelArray) {
        let array = label.split(',')
        this.cityCodeMap.set(array[0], array[1])
      }
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      console.error(`getRawFileContentSync failed, error code: ${code}, message: ${message}.`);
    }
  }

  build() {
    Column() {
      Row() {
        Text('在').fontSize(18)
        TextInput({text: $$this.cityName}).fontSize(18).layoutWeight(2)
        Text(this.middleText).fontSize(18)
        TextInput({text: $$this.searchText}).fontSize(18).layoutWeight(3)
      }.width('100%').height(45).padding(3)
      Row() {
        Select(this.typeArray).font({ size: 18 }).layoutWeight(1)
          .selected(this.index).value(this.typeArray[this.index].value)
          .onSelect((index:number, text?: string | undefined) => {
            this.index = index;
            this.middleText = index==0 ? '市内找' : '米内找'
            this.searchText = ''
          })
        Button('搜索').fontSize(17)
          .onClick(() => {
            this.searchPoi() // 搜索相关地点
          })
        Button('下一组').fontSize(17)
          .onClick(() => {
            this.pageIndex++
            this.searchPoi() // 搜索相关地点
          })
        Button('清除标记').fontSize(17)
          .onClick(() => {
            this.pageIndex = 1
            this.mapController?.clear() // 移除地图上所有的圆、标记、折线等覆盖物
          })
      }.width('100%').height(45).padding({top: 3, bottom: 3})
      // 调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%').layoutWeight(1)
    }
    .width('100%').height('100%')
  }

  // 搜索相关地点
  searchPoi() {
    if (this.searchText.length == 0) {
      this.promptAction.showToast({message: '请输入搜索关键字'})
      return
    }
    this.mapController?.clear() // 移除地图上所有的圆、标记、折线等覆盖物
    if (this.index ==0 ) {
      let cityCode = this.cityCodeMap.get(this.cityName)
      if (cityCode==undefined) {
        this.promptAction.showToast({message: '未找到城市：'+this.cityName})
        return
      }
      this.searchCity(cityCode) // 在指定城市内搜索
    } else if (this.index == 1) {
      if (this.cityName.length==0 || isNaN(Number(this.cityName))) {
        this.promptAction.showToast({message: '请输入距离'})
        return
      }
      let distance = Number(this.cityName)
      this.searchNearby(distance) // 在距离范围内搜索
    }
  }

  // 在指定城市内搜索
  searchCity(cityCode: string) {
    let params: site.SearchByTextParams = {
      query: this.searchText, // 搜索关键字
      cityId: cityCode, // 城市代码
      isCityLimit: true, // 是否限制城市
      radius: 5000, // 指定地理位置的范围半径，取值范围1-50000，默认50000
      pageIndex: this.pageIndex, // 第几页，取值范围1-500，默认1
      pageSize: 10, // 每页的结果数量，取值范围1-20，默认20
    };
    console.error('searchCity request: ' + JSON.stringify(params));
    // 返回关键字搜索结果
    site.searchByText(params).then(value => {
      console.error('site.searchByText success: ' + JSON.stringify(value));
      this.showMarkers(value) // 显示地点标记
    }).catch((err: BusinessError) => {
      console.error('site.searchByText failed with err: ' + JSON.stringify(err));
    })
  }

  // 在距离范围内搜索
  searchNearby(distance: number) {
    let params: site.NearbySearchParams = {
      query: this.searchText, // 搜索关键字
      location: { // 经纬度坐标
        latitude: this.myLocation!.latitude,
        longitude: this.myLocation!.longitude
      },
      radius: distance, // 指定地理位置的范围半径
      pageIndex: this.pageIndex, // 第几页
      pageSize: 10, // 每页的结果数量
    };
    console.error('searchNearby request: ' + JSON.stringify(params));
    // 返回关键字搜索结果
    site.nearbySearch(params).then(value => {
      console.error('site.nearbySearch success: ' + JSON.stringify(value));
      this.showMarkers(value) // 显示地点标记
    }).catch((err: BusinessError) => {
      console.error('site.nearbySearch failed with err: ' + JSON.stringify(err));
    })
  }

  // 显示地点标记
  showMarkers(result: site.SearchByTextResult) {
    if (result.totalCount == 0) {
      this.promptAction.showToast({message: '未找到任何结果'})
      return
    }
    if (result.sites == undefined) {
      this.promptAction.showToast({message: '未找到任何结果'})
      return
    }
    let location = result.sites[0].location
    let truePosition = MapUtil.convertPosition(location!.latitude, location!.longitude)
    let cameraUpdate = map.newLatLng(truePosition, 11)
    // 以动画方式移动地图相机
    this.mapController?.animateCamera(cameraUpdate, 300) // 动态切换相机视角
    for (let item of result.sites) {
      location = item.location
      truePosition = MapUtil.convertPosition(location!.latitude, location!.longitude)
      // 初始化marker（标记）参数
      let markerOptions: mapCommon.MarkerOptions = {
        position: truePosition, // 位置坐标
        clickable: true, // 是否允许点击
        title: item.name, // 信息窗口的标题
        snippet: item.formatAddress, // 信息窗口的副标题
        draggable: false // 是否允许拖动
      };
      this.mapController?.addMarker(markerOptions) // 添加指定位置的标记图标
    }
  }

}