import { bookParser, readerCore, ReadPageComponent } from '@kit.ReaderKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';

@Entry
@Component
struct EpubReaderPage {
  @State beginRead: boolean = false;
  @State bookTitle: string = '';
  @State pixelMap: PixelMap | undefined = undefined;
  // 确保在工程目录src/main/resources/resfile里存在kite.epub文档
  private fileName: string = 'lunyu.epub';
  private readerController = new readerCore.ReaderComponentController();
  // // 默认设置项，用于初始化阅读器页面的默认属性。
  // private readerSetting: readerCore.ReaderSetting = {
  //   fontName: '系统字体',
  //   fontPath: '', // 字体文件路径。支持resources/rawfile文件和应用沙箱文件
  //   fontSize: 18,
  //   fontColor: '#000000',
  //   fontWeight: 400,
  //   lineHeight: 1.9, // 行高系数。一行文本实际显示高度为fontSize * lineHeight
  //   nightMode: false, // 是否深色模式。true表示深色模式，false表示浅色模式
  //   themeColor: 'rgba(248, 249, 250, 1)', // 主题背景色
  //   themeBgImg: '', // 主题背景图。支持resources/rawfile文件和应用沙箱文件
  //   flipMode: '0', // 翻页方式。0表示仿真，1表示横滑
  //   scaledDensity: 1,
  //   // scaledDensity: display.getDefaultDisplaySync().scaledDensity > 0 ? display.getDefaultDisplaySync().scaledDensity :
  //   //   1,
  //   viewPortWidth: 370, // 视口宽度，需要根据设备实际情况获取
  //   viewPortHeight: 800, // 视口高度，需要根据设备实际情况获取
  // };
  // 书籍解析器，用于注册给组件控制器，供排版引擎调用。
  private parserHandler: bookParser.BookParserHandler | null = null;

  aboutToAppear() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let filePath = context.resourceDir + '/' + this.fileName;
    console.info('filePath: '+filePath);

    // https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/reader-read-page
    (async () => { // 异步方式加载电子书文档
      let spineIndex: number = 0;
      let domPos: string = '';
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      // 组件控制器初始化，用于控制ReadPageComponent调用排版引擎
      let initPromise = this.readerController.init(context);
      // 初始化书籍解析器
      let parserHandler = bookParser.getDefaultHandler(filePath);
      let result: [bookParser.BookParserHandler, void] = await Promise.all([parserHandler, initPromise]);
      this.parserHandler = result[0];

      // // 设置默认页面属性，用于排版的默认样式
      // this.readerController.setPageConfig(this.readerSetting);
      // 注册解析能力到控制器中，用于排版引擎的调用。
      this.readerController.registerBookParser(this.parserHandler);
      // 调用打开书籍接口，跳章至对应进度
      this.readerController.startPlay(spineIndex|| 0, domPos);

      let parserHandler2 = await bookParser.getDefaultHandler(filePath);
      // 获取书籍信息
      let bookInfo: bookParser.BookInfo = parserHandler2.getBookInfo();
      //获取书名
      this.bookTitle = bookInfo.bookTitle;
      console.info('bookTitle: '+bookInfo.bookTitle+', bookLanguage: '+bookInfo.bookLanguage+', bookType: '+bookInfo.bookType)
      // 获取书封不需要传入spineIndex
      let buffer = parserHandler2.getResourceContent(-1, bookInfo.bookCoverImage);
      let imageSource = image.createImageSource(buffer);
      this.pixelMap = imageSource.createPixelMapSync();
      imageSource.release();

      // 获取目录列表
      let catalogItemList = parserHandler2.getCatalogList() || [];

      // let parserHandler: bookParser.BookParserHandler = await bookParser.getDefaultHandler(filePath);
      // let spineList: bookParser.SpineItem[] = parserHandler.getSpineList();
      // let spineIndex: number = spineList[0].index;
      // let domPos: string = '';
      // let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      // this.readerController = new readerCore.ReaderComponentController();
      // await this.readerController.init(context);
      // this.readerController.startPlay(spineIndex || 0, domPos);
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
            Text(this.bookTitle).width('100%').fontSize(25).textAlign(TextAlign.Center)
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