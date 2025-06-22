import { scanCore, scanBarcode } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct BarcodeScanPage {
  context = this.getUIContext().getHostContext();
  private typeArray: Array<string> =[
    'FORMAT_UNKNOWN', 'AZTEC_CODE', 'CODABAR_CODE', 'CODE39_CODE', 'CODE93_CODE',
    'CODE128_CODE', 'DATAMATRIX_CODE', 'EAN8_CODE', 'EAN13_CODE', 'ITF14_CODE',
    'PDF417_CODE', 'QR_CODE', 'UPC_A_CODE', 'UPC_E_CODE', '' ];
  @State result: string = '扫码结果在这里'; // 扫码的识别结果文本

  // 开始扫描二维码
  startScan() {
    // 定义扫码参数options
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    };
    // 根据配置选项调用默认界面扫码
    scanBarcode.startScanForResult(this.context, options)
      .then((result: scanBarcode.ScanResult) => {
        console.info(`Succeeded in getting ScanResult, result is ${JSON.stringify(result)}`);
        // 收到正确的扫码返回
        this.result = `扫码类型为：${this.typeArray[result.scanType]}\n扫码结果为：${result.originalValue}`
      }).catch((error: BusinessError) => {
      if (error.code == scanCore.ScanErrorCode.SCAN_SERVICE_CANCELED) {
        console.info(`Disabling the Scanning Service.`);
      } else {
        console.error(`Failed to start the scanning service. Code: ${error.code}`);
      }
    });
  }

  build() {
    Column() {
      Button('开始扫码').width('100%').fontSize(18)
        .onClick(() => {
          this.startScan() // 开始扫描二维码
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }

}