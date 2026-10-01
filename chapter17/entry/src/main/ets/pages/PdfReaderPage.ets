import { common } from '@kit.AbilityKit';
import { pdfService, pdfViewManager, PdfView } from '@kit.PDFKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';

@Entry
@Component
struct PdfReaderPage {
  private controller = new pdfViewManager.PdfController();
  // 确保在工程目录src/main/resources/resfile里存在tangshi.pdf文档
  private fileName: string = 'tangshi.pdf';

  aboutToAppear() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let filePath = context.resourceDir + '/' + this.fileName;

    (async () => { // 异步方式加载PDF文档
      // 该监听方法只能在文档加载前调用一次
      this.controller.registerPageCountChangedListener((pageCount: number) => {
        console.info('pageCount='+pageCount.toString());
      });
      // 注意：这里刚加载文档，请不要在这里立即设置PDF文档的预览方式
      this.controller.loadDocument(filePath)
        .then((loadResult: pdfService.ParseResult) => {
          console.info('loadDocument successfully, loadResult is: ' + JSON.stringify(loadResult));
          // 设置非连续模式下的翻页方向（默认为垂直翻页）
          if (deviceInfo.distributionOSApiVersion >= 60000) {
            this.controller.setDisplayDirection(pdfViewManager.DisplayDirection.HORIZONTAL)
          } else {
            // Fallback to an earlier version
          }
        }).catch((err: BusinessError) => {
        console.error('loadDocument failed with err: ' + JSON.stringify(err));
      });
    })() // 末尾的一对括号必不可少，不然异步代码块就不会被执行
  }

  aboutToDisappear() {
    this.controller.releaseDocument();
  }

  build() {
    Column() {
      PdfView({
        controller: this.controller,
        // pageLayout: pdfService.PageLayout.LAYOUT_SINGLE, // 默认LAYOUT_SINGLE
        isContinuous: false, // 默认true
        // showScroll: true, // 默认true
        pageFit: pdfService.PageFit.FIT_WIDTH, // 默认FIT_NONE
      }).width('100%')
    }
    .width('100%').height('100%')
  }
}