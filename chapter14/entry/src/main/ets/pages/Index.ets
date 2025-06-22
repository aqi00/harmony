import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { GlobalThis } from '../utils/GlobalThis';

@Entry
@Component
struct Index {
  router = this.getUIContext().getRouter();
  context = this.getUIContext().getHostContext();
  private dataPref?: preferences.Preferences; // 首选项实例

  aboutToAppear() {
    GlobalThis.getInstance().setUIContext('ui_context', this.getUIContext());
    let options: preferences.Options = { name: 'user_store' };
    this.dataPref = preferences.getPreferencesSync(this.context, options);
  }

  build() {
    Column() {
      Text('14.1 传感器')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('传感器列表').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SensorListPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('加速度传感器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SensorAccelertePage' })
          })
        Button('磁场传感器-指南针').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SensorMagneticPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('光线传感器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SensorLightPage' })
          })
        Button('气压计传感器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SensorBarometerPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('计步器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SensorStepPage' })
          })
        Button('方向传感器-水平仪').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/SensorDirectionPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('14.2 定位服务')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('查看当前地址').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LocationAddressPage' })
          })
        Button('卫星浑天仪').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LocationSatellitePage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('14.3 地图导航')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('地图类型').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/MapBasicPage' })
          })
        Button('搜索地点').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/MapSearchPage' })
          })
        Button('路线导航').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/MapNavigationPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('14.4 实战项目：附近的人')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('仿微信的“附近的人”').fontSize(16).layoutWeight(1)
          .onClick(() => {
            let commitMyInfo = this.dataPref?.getSync('commitMyInfo', 'false') as string
            if (commitMyInfo == 'true') {
              this.router.pushUrl({ url: 'nearby/NearbyPage' })
            } else {
              this.router.pushUrl({ url: 'nearby/ChooseLocationPage' })
            }
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}