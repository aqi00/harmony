  import { deviceInfo } from'@kit.BasicServicesKit';

@Entry
@Component
struct DeviceInfoPage {
  @State result: string = ''; // 获取结果

  build() {
    Column() {
      Button('查看设备信息').width('100%').fontSize(18)
        .onClick(() => {
          this.result = `设备类型为${deviceInfo.deviceType}\n厂家名称为${deviceInfo.manufacture}\n`+
            `品牌名称为${deviceInfo.brand}\n市场名称为${deviceInfo.marketName}\n`+
            `产品系列为${deviceInfo.productSeries}\n认证型号为${deviceInfo.productModel}\n`+
            `设备序列号为${deviceInfo.serial}\n发布类型为${deviceInfo.osReleaseType}\n`+
            `系统版本为${deviceInfo.osFullName}\n系统软件API版本为${deviceInfo.sdkApiVersion}\n`+
            `发行版系统名称为${deviceInfo.distributionOSName}\n`+
            `发行版系统版本号为${deviceInfo.distributionOSVersion}\n`+
            `发行版系统API版本为${deviceInfo.distributionOSApiVersion}\n`+
            `发行版系统API版本名称为${deviceInfo.distributionOSApiName}\n`
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}