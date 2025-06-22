import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';

import {
  DocType,
  DocumentScanner,
  DocumentScannerConfig,
  SaveOption,
  FilterId,
  ShootingMode
} from '@kit.VisionKit'

@Entry
@Component
export struct DocScannerPage {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State docImageUris: string[] = [];
  @State scanVisibility: Visibility = Visibility.Visible;
  private docScanConfig = new DocumentScannerConfig();
  @State result: string = ' ';

  // 保存扫描后的图片
  saveImage(uri: string) {
    let fileName = uri.toString().split('/').pop() as string
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [fileName];
    let documentPicker = new picker.DocumentViewPicker(this.context);
    documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      console.info('DocumentViewPicker.save successfully, documentSaveResult uri: ' + JSON.stringify(documentSaveResult));
      if (documentSaveResult.length == 0) {
        this.result = '请选择文件路径'
        return;
      }
      let dstPath = documentSaveResult[0]
      console.info('write filePath: ' + dstPath);
      let srcFile = fileIo.openSync(uri.toString());
      let dstFile = fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.copyFileSync(srcFile.fd, dstFile.fd);
      fileIo.closeSync(srcFile);
      fileIo.closeSync(dstFile);
      this.result = '文件保存成功：'+dstPath
    }).catch((err: BusinessError) => {
      console.error('DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
      this.result = '文件保存失败'
    });
  }

  aboutToAppear() {
    this.docScanConfig.supportType = [DocType.DOC, DocType.SHEET]
    this.docScanConfig.isGallerySupported = true
    this.docScanConfig.editTabs = []
    this.docScanConfig.maxShotCount = 3
    this.docScanConfig.defaultFilterId = FilterId.ORIGINAL
    this.docScanConfig.defaultShootingMode = ShootingMode.MANUAL
    this.docScanConfig.isShareable = true
    this.docScanConfig.originalUris = []
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      //展示文档扫描结果
      if (this.docImageUris && this.docImageUris.length>0) {
        Column() {
          Button('保存图片').width('100%').fontSize(18)
            .onClick(() => {
              this.saveImage(this.docImageUris[0]) // 保存扫描后的图片
            })
          Image(this.docImageUris[0]).width('100%').height('60%').objectFit(ImageFit.Contain)
          Text(this.result).width('100%').padding(5).fontSize(18)
        }
        .width('100%').height('100%')
      }

      DocumentScanner({
        scannerConfig: this.docScanConfig,
        onResult: (code: number, saveType: SaveOption, uris: string[]) => {
          console.info(`result code: ${code}, save: ${saveType}`)
          uris.forEach(uriString => {
            console.info(`uri: ${uriString}`)
          })
          this.docImageUris = uris
          this.scanVisibility = Visibility.Hidden
        }
      }).visibility(this.scanVisibility)
        .size({ width: '100%', height: '100%' })
    }
    .width('100%').height('100%')
  }
}