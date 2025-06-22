import { image } from '@kit.ImageKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanCore, generateBarcode } from '@kit.ScanKit';

import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';

@Entry
@Component
struct BarcodeCreatePage {
  promptAction = this.getUIContext().getPromptAction();
  @State pixelMap: PixelMap | undefined = undefined; // 二维码的像素图
  @State mContent: string = '离离原上草，一岁一枯荣。'; // 默认设置二维码内容
  @State mScanType: number = scanCore.ScanType.QR_CODE; // 默认设置二维码类型 - QR码
  @State mWidth: string = '800'; // 默认设置二维码宽度，单位px
  @State mHeight: string = '800'; // 默认设置二维码高度，单位px
  @State mMargin: string = '10'; // 默认设置二维码边距，单位px。取值范围1-10
  @State mLevel: generateBarcode.ErrorCorrectionLevel = generateBarcode.ErrorCorrectionLevel.LEVEL_H; // 默认设置二维码容错率
  @State mBackgroundColor: number = 0xffffff; // 默认设置二维码背景色
  @State mPixelMapColor: number = 0x000000; // 默认设置二维码颜色

  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED,
    text: SaveDescription.SAVE_IMAGE,
    buttonType: ButtonType.Capsule
  };

  // 把像素图保存到相册
  savePixelMapToAlbum(pixmap: image.PixelMap) {
    let helper = photoAccessHelper.getPhotoAccessHelper(this.context);
    // 只能在安全控件SaveButton中调用
    helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', (err, uri) => {
      if (uri !== undefined) {
        console.info('createAsset uri: ' + uri);
        let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        let imagePackerApi = image.createImagePacker();
        let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 80 };

        imagePackerApi.packToFile(pixmap, file.fd, packOpts, (err: BusinessError) => {
          if (err) {
            console.error(`Failed to pack the image to file.code ${err.code},message is ${err.message}`);
          } else {
            console.info('Succeeded in packing the image to file.');
            this.promptAction.showToast({ message: '已将二维码图片已保存至相册' });
          }
        })
      } else {
        console.error(`createAsset failed, error: ${err.code}, ${err.message}`);
      }
    });
  }
  build() {
    Column() {
      Row() {
        // 设置二维码的文本内容
        Text('码内容：').height('100%').fontSize(15)
        TextArea({text: $$this.mContent})
          .height('100%').layoutWeight(1).fontSize(15).align(Alignment.Center)
      }.width('100%').height(40).margin(3)

      // 设置二维码的宽度和高度
      Row() {
        Text('码宽度：').height('100%').fontSize(15)
        TextInput({text: $$this.mWidth})
          .height('100%').layoutWeight(1).fontSize(15).type(InputType.Number)
        Text('码高度：').height('100%').fontSize(15)
        TextInput({text: $$this.mHeight})
          .height('100%').layoutWeight(1).fontSize(15).type(InputType.Number)
      }.width('100%').height(40).margin(3)

      // 设置二维码的类型和边距
      Row() {
        Text('码类型：').height('100%').fontSize(15)
        Select(ScanConstant.codeTypeItems)
          .height('100%').layoutWeight(1).font({ size: 15 })
          .selected(10).value('QR_CODE')
          .onSelect((index: number, value?: string) => {
            console.info(`Succeeded in selecting scanType, index is ${index}`);
            this.mScanType = getTypeNum(value);
          })
        Text('码边距：').height('100%').fontSize(15)
        TextInput({text: $$this.mMargin})
          .height('100%').layoutWeight(1).fontSize(15).type(InputType.Number)
      }.width('100%').height(40).margin(3)

      // 设置二维码的颜色和背景色
      Row() {
        Text('码颜色：').height('100%').fontSize(15)
        Select(ScanConstant.colorItems)
          .height('100%').layoutWeight(1).font({ size: 15 })
          .selected(0).value('Black')
          .onSelect((index: number, value?: string) => {
            console.info(`Succeeded in selecting pixelMapColor, index is ${index}`);
            this.mPixelMapColor = getColorType(value);
          })
        Text('背景色：').height('100%').fontSize(15)
        Select(ScanConstant.colorItems)
          .height('100%').layoutWeight(1).font({ size: 15 })
          .selected(7).value('White')
          .onSelect((index: number, value?: string) => {
            console.info(`Succeeded in selecting backgroundColor, index is ${index}`);
            this.mBackgroundColor = getColorType(value);
          })
      }.width('100%').height(40).margin(3)

      // 设置二维码纠错水平
      Row() {
        Text('纠错水平：').height('100%').fontSize(15)
        Select(ScanConstant.errorLevelItems)
          .height('100%').layoutWeight(1).font({ size: 15 })
          .selected(3).value('LEVEL_H')
          .onSelect((index: number, value?: string) => {
            console.info(`Succeeded in selecting errorLevel, index is ${index}`);
            this.mLevel = getLevelType(value);
          })
      }.width('100%').height(40).margin(3)

      // 通过文本生成生成码
      Button('生成二维码')
        .width('100%').fontSize(15).margin(3)
        .onClick(() => {
          this.pixelMap = undefined;
          let content = this.mContent;
          let options: generateBarcode.CreateOptions = {
            scanType: this.mScanType, // 码类型
            width: Number(this.mWidth), // 码图宽
            height: Number(this.mHeight), // 码图高
            margin: Number(this.mMargin), // 码边距
            level: this.mLevel, // 纠错水平
            backgroundColor: this.mBackgroundColor, // 背景色
            pixelMapColor: this.mPixelMapColor, // 码图色
          }
          // 创建二维码
          generateBarcode.createBarcode(content, options).then((result: image.PixelMap) => {
            this.pixelMap = result;
          }).catch((error: BusinessError) => {
            console.error(`Failed to get pixelMap. Code: ${error.code}, message: ${error.message}`);
          })
        })

      // 生成二维码，图片显示尺寸(300, 300)
      if (this.pixelMap) {
        Image(this.pixelMap).width(300).height(300).margin(3).objectFit(ImageFit.Contain)
        // 创建安全控件按钮，不得另外设置width、fontSize等属性
        SaveButton(this.saveButtonOptions)
          .onClick(async (event, result: SaveButtonOnClickResult) => {
            if (result == SaveButtonOnClickResult.SUCCESS) {
              this.savePixelMapToAlbum(this.pixelMap!) // 把像素图保存到相册
            }
          })
      }
    }
    .width('100%').height('100%').padding(3)
  }
}

export default class ScanConstant {
  static readonly qr_code: Record<string, string> = {
    'scanType': 'qrcode', 'originalValue': 'TEC-IT'
  }
  static readonly colorItems: Array<SelectOption> = [
    { value: 'Black' }, { value: 'Blue' }, { value: 'Brown' }, { value: 'Gray' }, { value: 'Green' },
    { value: 'Orange' }, { value: 'Red' }, { value: 'White' }, { value: 'Yellow' }];
  static readonly errorLevelItems: Array<SelectOption> = [
    { value: 'LEVEL_L' }, { value: 'LEVEL_M' }, { value: 'LEVEL_Q' }, { value: 'LEVEL_H' }];
  static readonly codeTypeItems: Array<SelectOption> = [
    { value: 'AZTEC_CODE' }, { value: 'CODABAR_CODE' }, { value: 'CODE93_CODE' }, { value: 'CODE39_CODE' },
    { value: 'CODE128_CODE' }, { value: 'DATAMATRIX_CODE' }, { value: 'EAN8_CODE' }, { value: 'EAN13_CODE' },
    { value: 'ITF14_CODE' }, { value: 'PDF417_CODE' }, { value: 'QR_CODE' },  { value: 'UPC_A_CODE' },
    { value: 'UPC_E_CODE' }];
}

function getLevelType(type?: string): generateBarcode.ErrorCorrectionLevel {
  let result: generateBarcode.ErrorCorrectionLevel = generateBarcode.ErrorCorrectionLevel.LEVEL_H;
  switch (type) {
    case 'LEVEL_L':
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_L;
      break;
    case 'LEVEL_M':
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_M;
      break;
    case 'LEVEL_Q':
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_Q;
      break;
    case 'LEVEL_H':
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_H;
      break;
    default:
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_H;
      break;
  }
  return result;
}

function getColorType(type?: string): number {
  let color: number = 0x000000;
  switch (type) {
    case 'Black':
      color = 0x000000;
      break;
    case 'Blue':
      color = 0x0000ff;
      break;
    case 'Brown':
      color = 0xa52a2a;
      break;
    case 'Gray':
      color = 0x808080;
      break;
    case 'Green':
      color = 0x008000;
      break;
    case 'Orange':
      color = 0xffa500;
      break;
    case 'Red':
      color = 0xff0000;
      break;
    case 'White':
      color = 0xffffff;
      break;
    case 'Yellow':
      color = 0xffff00;
      break;
    default:
      color = 0x1e1e1e;
      break;
  }
  return color;
}

function getTypeNum(type?: string): scanCore.ScanType {
  let result: scanCore.ScanType = scanCore.ScanType.QR_CODE;
  switch (type) {
    case 'AZTEC_CODE':
      result = scanCore.ScanType.AZTEC_CODE;
      break;
    case 'CODABAR_CODE':
      result = scanCore.ScanType.CODABAR_CODE;
      break;
    case 'CODE39_CODE':
      result = scanCore.ScanType.CODE39_CODE;
      break;
    case 'CODE93_CODE':
      result = scanCore.ScanType.CODE93_CODE;
      break;
    case 'CODE128_CODE':
      result = scanCore.ScanType.CODE128_CODE;
      break;
    case 'DATAMATRIX_CODE':
      result = scanCore.ScanType.DATAMATRIX_CODE;
      break;
    case 'EAN8_CODE':
      result = scanCore.ScanType.EAN8_CODE;
      break;
    case 'EAN13_CODE':
      result = scanCore.ScanType.EAN13_CODE;
      break;
    case 'ITF14_CODE':
      result = scanCore.ScanType.ITF14_CODE;
      break;
    case 'PDF417_CODE':
      result = scanCore.ScanType.PDF417_CODE;
      break;
    case 'QR_CODE':
      result = scanCore.ScanType.QR_CODE;
      break;
    case 'UPC_A_CODE':
      result = scanCore.ScanType.UPC_A_CODE;
      break;
    case 'UPC_E_CODE':
      result = scanCore.ScanType.UPC_E_CODE;
      break;
    default:
      result = scanCore.ScanType.QR_CODE;
      break;
  }
  return result;
}