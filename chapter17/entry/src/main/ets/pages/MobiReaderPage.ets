import { bookParser, readerCore, ReadPageComponent } from '@kit.ReaderKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';

@Entry
@Component
struct MobiReaderPage {
  @State beginRead: boolean = false;
  @State bookTitle: string = '';
  @State pixelMap: PixelMap | undefined = undefined;
  // 确保在工程目录src/main/resources/resfile里存在kite.mobi文档
  private fileName: string = 'kite.mobi';
  private readerController = new readerCore.ReaderComponentController();

  aboutToAppear() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let filePath = context.resourceDir + '/' + this.fileName;
    console.info('filePath: '+filePath);

    (async () => { // 异步方式加载电子书文档
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      // 组件控制器初始化，用于控制ReadPageComponent调用排版引擎
      this.readerController.init(context);
      // 初始化书籍解析器
      let parserHandler = await bookParser.getDefaultHandler(filePath);
      // 注册解析能力到控制器中，用于排版引擎的调用。
      this.readerController.registerBookParser(parserHandler);
      // 调用打开书籍接口，跳章至对应进度
      this.readerController.startPlay(0, '');

      // 获取书籍信息
      let bookInfo: bookParser.BookInfo = parserHandler.getBookInfo();
      //获取书名
      this.bookTitle = bookInfo.bookTitle;
      console.info('bookTitle: '+bookInfo.bookTitle+', bookLanguage: '+bookInfo.bookLanguage+', bookType: '+bookInfo.bookType)
      // 获取书封不需要传入spineIndex
      let buffer = parserHandler.getResourceContent(-1, bookInfo.bookCoverImage);
      let imageSource = image.createImageSource(buffer);
      this.pixelMap = imageSource.createPixelMapSync();
      imageSource.release();
    })() // 末尾的一对括号必不可少，不然异步代码块就不会被执行
  }

  aboutToDisappear() {
    this.readerController.releaseBook() // 退出需要释放阅读器实例
  }

  build() {
    Column() {
      Stack() {
        ReadPageComponent({
          controller: this.readerController,
          readerCallback: (_err: BusinessError, data: readerCore.ReaderComponentController) => {
            this.readerController = data;
          }
        }).visibility(this.beginRead?Visibility.Visible:Visibility.Hidden)
        if (!this.beginRead) {
          Column() {
            Text(this.bookTitle).width('100%').fontSize(20).textAlign(TextAlign.Center)
            Image(this.pixelMap).width('100%').layoutWeight(1).objectFit(ImageFit.Contain)
            Button('开始阅读').width('100%').fontSize(17)
              .onClick(() => {
                this.beginRead = true
              })
          }.width('100%').height('100%').padding({top:10})
        }
      }.width('100%').height('100%')
      .onClick(() => {
        // 支持在此实现点击拉起菜单栏功能
      })
    }.width('100%')
  }
}