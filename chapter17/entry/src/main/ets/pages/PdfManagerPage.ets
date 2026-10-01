import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { picker } from '@kit.CoreFileKit';
import { pdfService } from '@kit.PDFKit';

@Entry
@Component
struct PdfManagerPage {
  promptAction = this.getUIContext().getPromptAction();
  private fileName: string = 'zhinengti.pdf';
  @State filePath: string = '';
  @State pageCount: number = 0;
  @State pageIndex: number = 0;
  @State pixelMap: PixelMap | undefined = undefined;
  private document: pdfService.PdfDocument = new pdfService.PdfDocument;
  private originPath: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private imageDir = this.context.filesDir + '/outputImg';
  @State scaleValue: number = 1; // 当前缩放比例
  private startScale: number = 1; // 手势开始时记录的缩放比例

  aboutToAppear(): void {
    let fileList = fileIo.listFileSync(this.context.filesDir)
    for (let file of fileList) {
      console.info('file: ' + file);
    }
    fileIo.mkdir(this.imageDir);
    if (fileIo.accessSync(this.imageDir)) {
      let subFileList = fileIo.listFileSync(this.imageDir)
      for (let subfile of subFileList) {
        console.info('subfile: ' + subfile);
      }
    }
    this.filePath = this.context.resourceDir + '/' + this.fileName;
    this.parserPdf() // 解析PDF文件
  }

  aboutToDisappear() {
    this.document.releaseDocument();
  }

  choosePdf() {
    // 拷贝文件到沙盒中，并push到下一个pdfViewer页面，展示功能
    const documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1; // 选择文档的最大数目（可选）
    documentSelectOptions.fileSuffixFilters = ['.pdf']; // 选择文件的后缀类型，若选择项存在多个后缀名，则每一个后缀名之间用英文逗号进行分隔（可选）
    let documentViewPicker = new picker.DocumentViewPicker(); // 创建文件选择器实例
    documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
      this.originPath = documentSelectResult[0]
      this.copyFile(this.originPath) // 把选中的PDF文件复制到应用沙箱
      this.parserPdf() // 解析PDF文件
      console.info('documentViewPicker.select to file succeed and uri are:' + this.originPath);
    }).catch((err: BusinessError) => {
      console.info(`Invoke documentViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    })
  }

  copyFile(uri: string) {
    let dir = this.context.filesDir;
    let dstPath = dir + '/temp.pdf';
    console.info('[rawfile_copy_to_sandbox] 路径为 :' + dstPath);
    let srcFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    let dstFile = fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.copyFileSync(srcFile.fd, dstFile.fd)
    fileIo.closeSync(srcFile);
    fileIo.closeSync(dstFile);
    this.filePath = dstPath
  }

  parserPdf() {
    let t0 = Date.now();
    this.document.loadDocument(this.filePath, '');
    let t1 = Date.now();
    console.info('loadDocument cost time：' + (t1 - t0));
    let page: pdfService.PdfPage = this.document.getPage(0); //默认第一页
    this.pixelMap = page.getPagePixelMap(); //设置Image组件参数
  }
  
  build() {
    Column() {
      Row() {
        Button('打开PDF文件').fontSize(15)
          .onClick(() => {
            this.choosePdf()
          })
        Button('上一页').fontSize(15).layoutWeight(1)
          .onClick(async () => {
            this.pageIndex--;
            if (this.pageIndex < 0) {
              this.promptAction.showToast({ message: '已是第一页' })
              this.pageIndex++;
              return;
            }
            let page: pdfService.PdfPage = this.document.getPage(this.pageIndex); //设置页面为上一页
            this.pixelMap = page.getPagePixelMap(); //设置Image组件参数
          })
        Button('下一页').fontSize(15).layoutWeight(1)
          .onClick(async () => {
            this.pageIndex++;
            if (this.pageIndex >= this.document.getPageCount()) {
              this.promptAction.showToast({ message: '已是最后一页' })
              this.pageIndex--;
              return;
            }
            let page: pdfService.PdfPage = this.document.getPage(this.pageIndex); //设置页面为下一页
            this.pixelMap = page.getPagePixelMap(); // 设置Image组件参数
          })
      }.zIndex(2)
      Row() {
        // 显示内容
        Image(this.pixelMap).width('100%').height('100%')
          .objectFit(ImageFit.Contain).border({ width: 1, color: Color.Blue })
        // 通过 scale 属性应用缩放
          .scale({
            x: this.scaleValue,
            y: this.scaleValue
          })
          // 绑定捏合手势
          .gesture(
            PinchGesture()
              .onActionStart(() => {
                // 手势开始时，记录当前缩放值作为基准
                this.startScale = this.scaleValue;
              })
              .onActionUpdate((event: GestureEvent) => {
                // event.scale 为相对于手势开始时的缩放比例
                // 限制缩放范围在 0.5 ~ 3.0 之间
                this.scaleValue = Math.max(0.5, Math.min(3.0, this.startScale * event.scale));
              })
              .onActionEnd(() => {
                // 手势结束，可在此处做边界回弹等处理
              })
          )
      }.layoutWeight(1).zIndex(1)
      Row() {
        Button('PDF转图片').fontSize(15).layoutWeight(1)
          .onClick(async () => {
            console.info('saveDir: '+this.imageDir)
            //将整个PDF文件转为图片
            let result = this.document.convertToImage(this.imageDir, pdfService.ImageFormat.PNG);
            if (result) {
              this.promptAction.showToast({ message: 'PDF转图片成功，存储目录为：'+this.imageDir })
            } else {
              this.promptAction.showToast({ message: 'PDF转图片失败，请检查用户权限' })
            }
          })
        Button('打开PDF图片').fontSize(15).layoutWeight(1)
          .onClick(async () => {
            let imagePath = `${this.imageDir}/1.png`
            console.info('imagePath: '+imagePath)
            if (fileIo.accessSync(this.imageDir)) {
              let file = fileIo.openSync(imagePath, fileIo.OpenMode.READ_ONLY);
              let imageSource = image.createImageSource(file.fd);
              this.pixelMap = imageSource.createPixelMapSync()
            } else {
              this.promptAction.showToast({ message: '未找到PDF图片，请先将PDF转图片' })
            }
          })
        Button('保存PDF文件').fontSize(15).layoutWeight(1)
          .onClick(async () => {
            //let savePath = this.context.filesDir + '/output.pdf';
            let fileName = this.originPath.toString().split('/').pop() as string
            let savePath = `${this.context.filesDir}/${fileName}`
            console.info('savePath: '+savePath)
            let result = this.document.saveDocument(savePath); //保存文件
            if (result) {
              this.promptAction.showToast({ message: 'PDF保存成功，存储路径为：'+savePath })
            } else {
              this.promptAction.showToast({ message: 'PDF保存失败，请检查用户权限' })
            }
          })
      }.zIndex(2)
    }
    .width('100%')
  }
}