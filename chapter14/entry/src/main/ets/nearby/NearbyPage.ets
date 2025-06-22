import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { MapUtil } from '../utils/MapUtil'

import { navi } from '@kit.MapKit';
import { http } from '@kit.NetworkKit';
import { Constants } from '../constant/Constants';
import { QueryResponse } from '../entity/QueryResponse';
import { PersonInfo } from '../entity/PersonInfo';
import { PersonDialog } from '../view/PersonDialog';
import { call } from '@kit.TelephonyKit';

import { image } from '@kit.ImageKit';
import { Utils } from '../utils/Utils'
import { common } from '@kit.AbilityKit';
import { request } from '@kit.BasicServicesKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';

// 打开拨号页面
function openCallPage(phone: string) {
  let isSupport = call.hasVoiceCapability();
  if (!isSupport) {
    console.error('Not support voice capability.');
    return;
  }
  call.makeCall(phone) // 跳到待拨打号码的拨号页面
}

@Entry
@Component
struct NearbyPage {
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext();
  // 注意这里的URL地址要换成读者在自己WiFi环境下的IP和端口
  private url: string = Constants.URL_PREFIX + 'queryNearby'; // 查询附近的人接口的完整地址
  private isFirstLoc: boolean = true; // 是否首次定位
  private mapController?: map.MapComponentController; // 地图组件控制器
  private mapEventManager?: map.MapEventManager; // 地图事件管理器
  // 地图初始化参数，设置地图中心点坐标及层级
  private target: mapCommon.LatLng = {
    latitude: 39.9181,
    longitude: 116.3970193
  };
  private cameraPosition: mapCommon.CameraPosition = {
    target: this.target,
    zoom: 15
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
      this.mapEventManager.on('markerClick', (marker) => {
        // 传给自定义对话框的变量必须为@State，否则App会崩溃
        this.clickPerson = marker.getTag() as PersonInfo
        // 对话框控制器必须是页面的属性变量，否则调用close不会关闭
        this.dialogController = new CustomDialogController({
            builder: PersonDialog({
              person: $clickPerson, // 注意，变量名前面加$，不加this.
              dial: (person: PersonInfo): void => this.dial(person),
              route: (person: PersonInfo): void => this.route(person)
            }),
            customStyle: false,
            alignment: DialogAlignment.Center
          });
        this.dialogController.open() // 打开自定义对话框
      })
      this.getLocation() // 获取当前位置
    }
  }
  @State clickPerson: PersonInfo|undefined = undefined; // 选中的人员信息
  private dialogController: CustomDialogController|undefined = undefined;

  // 拨号
  dial(person: PersonInfo) {
    console.info('PersonDialog:dial()')
    openCallPage(person.phone)// 打开拨号页面
  }

  // 到他/她那里
  route(person: PersonInfo) {
    this.showPersonMarker() // 显示附近人员标记
    console.info('PersonDialog:route()')
    let otherPos: mapCommon.LatLng = {
      latitude: person.latitude,
      longitude: person.longitude
    };
    this.getDrivingRoute(this.myPos!, otherPos) // 获取行车导航
  }

  aboutToDisappear() {
    this.mapEventManager?.off('markerClick')
  }

  // 显示我的位置
  showMyLocation(location: geoLocationManager.Location) {
    // 注意：不能直接用定位的location，要先把latitude和longitude复制过来，其他字段清零
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
        this.queryNearbyList() // 查询附近的人列表
      }
    }).catch((error: BusinessError) => {
      console.error('promise, getCurrentLocation: error=' + JSON.stringify(error));
    });
  }

  @State sexIndex: number = 0;
  sexArray: Array<SelectOption> = [ { value: '看所有人' },
    { value: '只看男生' }, { value: '只看女生' } ];
  @State loveIndex: number = 0;
  loveArray: Array<SelectOption> = [ { value: '找所有爱好' },
    { value: '唱歌' }, { value: '跳舞' }, { value: '绘画' },
    { value: '弹琴' }, { value: '摄影' }, { value: '出售闲置物品' } ];
  private myPos?: mapCommon.LatLng; // 我的位置
  @State personList: Array<PersonInfo> = []; // 附近的人员列表

  build() {
    Column() {
      Text('附近的人').fontSize(20)
      Row() {
        Text('性别：').fontSize(17)
        Select(this.sexArray).font({ size: 17 }).layoutWeight(0.9)
          .selected(this.sexIndex).value(this.sexArray[this.sexIndex].value)
          .onSelect((index:number, text?: string | undefined) => {
            this.sexIndex = index;
            this.showPersonMarker() // 显示附近人员标记
          })
        Text('爱好：').fontSize(17)
        Select(this.loveArray).font({ size: 17 }).layoutWeight(1)
          .selected(this.loveIndex).value(this.loveArray[this.loveIndex].value)
          .onSelect((index:number, text?: string | undefined) => {
            this.loveIndex = index;
            this.showPersonMarker() // 显示附近人员标记
          })
      }.width('100%').padding({ top:5, bottom: 5 })
      // 调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%').layoutWeight(1)
    }
    .width('100%').height('100%')
  }

  // 查询附近的人列表
  queryNearbyList() {
    // 每个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 订阅HTTP响应头事件
    httpRequest.on('headersReceive', (header: Object) => {
      console.info('header: ' + JSON.stringify(header));
    });
    let options: http.HttpRequestOptions ={
      method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
      readTimeout: 12000, // 可选，默认为60000ms
      connectTimeout: 12000, // 可选，默认为60000ms
    }
    // 根据URL地址，发起HTTP网络请求，使用callback方式作为异步方法。
    httpRequest.request(this.url, options,
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          let result = data.result.toString()
          console.info('result: ' + result);
          let resp = JSON.parse(result) as QueryResponse
          this.personList = resp.personList
          console.info('this.personList.length: ' + this.personList.length);
          this.showPersonMarker() // 显示附近人员标记
        } else {
          console.info('error:' + JSON.stringify(err));
        }
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript对象
        httpRequest.destroy();
      })
  }

  // 显示附近人员标记
  showPersonMarker() {
    this.mapController?.clear() // 移除地图上所有的圆、标记、折线等覆盖物
    let seq = 0
    for (let person of this.personList) {
      if (this.sexIndex>0 && (this.sexIndex-1)!=person.sex) {
        continue
      }
      if (this.loveIndex>0 && this.loveArray[this.loveIndex].value!=person.love) {
        continue
      }
      //this.addNearbyMarker(person) // 添加附近人员的标记
      this.loadNearbyMarker(seq++, person) // 加载附近人员的标记
    }
  }

  // 获取行车导航
  getDrivingRoute(beginPos: mapCommon.LatLng, endPos: mapCommon.LatLng) {
    console.info('begin getDrivingRoute');
    console.info('beginPos: '+JSON.stringify(beginPos));
    console.info('endPos: '+JSON.stringify(endPos));
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
      points: lines,
      color: 0xff0000ff, // 注意，这里不能用Color.Blue
      width: 20,
    }
    console.warn('addPolyline: ' + JSON.stringify(options))
    this.mapController?.addPolyline(options) // 在地图上添加折线
  }

  // 添加附近人员的标记
  addNearbyMarker(person: PersonInfo, pixelMap: image.PixelMap) {
    let position: mapCommon.LatLng = {
      latitude: person.latitude,
      longitude: person.longitude
    };
    // 初始化marker（标记）参数
    let markerOptions: mapCommon.MarkerOptions = {
      position: position, // 位置坐标
      clickable: true, // 是否允许点击
      title: person.name, // 信息窗口的标题
      snippet: person.address, // 信息窗口的副标题
      icon: pixelMap, // 标记图标
      //icon: $r('app.media.icon_current'), // 标记图标
      // icon看来不能用网络图片
      //icon: Constants.URL_PREFIX + personInfo.face, // 标记图标
      draggable: false // 是否允许拖动
    };
    // 添加指定位置的标记图标
    this.mapController?.addMarker(markerOptions).then(marker => {
      marker.setTag(person) // 给标记添加额外的标签信息
    });
  }

  // 加载附近人员的标记
  loadNearbyMarker(seq: number, person: PersonInfo) {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext
    let fileName = `${Utils.getNowDatetime()}_${seq}.jpg`
    let filePath = context.filesDir + '/' + fileName
    console.info('write filePath: ' + filePath);
    // 设定下载配置
    let config: request.DownloadConfig = {
      url: Constants.URL_PREFIX + person.face, // 请求地址
      header: { // 请求包头
        'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN',
      },
      // 允许连上WIFI或者蜂窝网络时下载
      networkType: request.NETWORK_WIFI | request.NETWORK_MOBILE,
      filePath: filePath }
    let downloadTask: request.DownloadTask; // 下载任务
    // 请求下载网络文件
    request.downloadFile(this.context, config).then(data => {
      downloadTask = data;
      // 订阅下载完成事件
      downloadTask.on('complete', () => {
        fileUri.getUriFromPath(filePath)
        let imageSource = image.createImageSource(filePath)
        imageSource.createPixelMap().then((pixelMap) => {
          this.addNearbyMarker(person, pixelMap) // 添加附近人员的标记
        }).catch((err: BusinessError) => {
          console.error('createPixelMap failed with err: ' + JSON.stringify(err));
        });
      })
    }).catch((err: BusinessError) => {
      console.error('Failed to request the download. Cause: ' + JSON.stringify(err));
    })
  }

}