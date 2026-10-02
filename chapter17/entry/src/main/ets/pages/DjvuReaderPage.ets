/**
 * DJVU 阅读器入口页（对应 Android DjvuRenderActivity + activity_djvu_render.xml
 * + fragment_image.xml + PdfPageAdapter/ImageFragment）。
 *
 * 生命周期：aboutToAppear → 准备文件 → open → 渲染前 2 页 → 隐藏加载层；
 * onPageHide/aboutToDisappear → recycle。
 */
import common from '@ohos.app.ability.common';
import display from '@ohos.display';
import image from '@ohos.multimedia.image';

import { DecodeService } from '../reader/DecodeService';
import { FileUtil } from '../reader/FileUtil';
import { RenderConst } from '../reader/RenderConst';

const TAG = 'DjvuRenderPage';

@Entry
@Component
struct DjvuReaderPage {
  @State isLoading: boolean = true;
  @State title: string = 'DJVU电子书';
  @State pageCount: number = 0;
  @State currentIndex: number = 0;
  // 各页 PixelMap（内存缓存，命中则直接显示）。
  @State pageBitmaps: Array<PixelMap | undefined> = [];
  // 各页是否就绪（已解码或磁盘缓存命中）。
  @State pageReady: Array<boolean> = [];
  @State hasError: boolean = false;
  @State errorMsg: string = '';

  private decodeService: DecodeService = new DecodeService();
  private paths: string[] = [];
  private imgDir: string = '';
  private rootDir: string = '';
  private fileName: string = 'sample.djvu';
  private containerWidth: number = 1080;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private inFlight: Set<number> = new Set<number>();
  private cleaned: boolean = false;

  async aboutToAppear() {
    console.info('aboutToAppear')
    try {
      // 1. 准备 DJVU 文件（resfile → 沙盒）
      let filePath = this.context.resourceDir + '/' + this.fileName;
      this.rootDir = `${this.context.filesDir}/djvu`;
      this.imgDir = `${this.rootDir}/${FileUtil.md5Digest(this.fileName)}`;
      FileUtil.ensureDir(this.imgDir);
      // 2. 取内容区宽度（px）作为渲染目标宽
      this.containerWidth = this.getContainerWidth();
      console.info('containerWidth='+this.containerWidth)
      // 3. 打开文档（worker 线程，等待 DOCINFO）
      console.info('filePath='+filePath)
      this.pageCount = await this.decodeService.open(filePath);
      console.info('pageCount='+this.pageCount)
      // 4. 构建图片缓存路径列表（对齐 Android L109-112）
      this.paths = [];
      this.pageBitmaps = new Array<PixelMap | undefined>(this.pageCount).fill(undefined);
      this.pageReady = new Array<boolean>(this.pageCount).fill(false);
      for (let i = 0; i < this.pageCount; i++) {
        this.paths.push(`${this.imgDir}/${FileUtil.pad3(i)}.jpg`);
      }
      // 5. 先加载前 2 页（对齐 DjvuRenderActivity.doNext 的 mIndex<2 分支）
      const preload = Math.min(RenderConst.PRELOAD_PAGES, this.pageCount);
      for (let i = 0; i < preload; i++) {
        await this.ensureDecoded(i);
      }
      this.currentIndex = 0;
      this.isLoading = false;
    } catch (e) {
      console.error(`${TAG} aboutToAppear fail: ${e}`);
      this.errorMsg = String(e);
      this.hasError = true;
      this.isLoading = false;
    }
  }

  onPageHide() {
    this.cleanup();
  }

  aboutToDisappear() {
    this.cleanup();
  }

  private async cleanup() {
    console.info('cleanup')
    if (this.cleaned) {
      return;
    }
    this.cleaned = true;
    try {
      await this.decodeService.recycle();
    } catch (e) {
      console.error(`${TAG} recycle fail: ${e}`);
    }
    this.decodeService.terminate();
  }

  private getContainerWidth(): number {
    try {
      const d = display.getDefaultDisplaySync();
      return d.width > 0 ? d.width : 1080;
    } catch (e) {
      return 1080;
    }
  }

  /**
   * 确保某页已就绪（对应 Android ImageFragment.onCreateView 的三分支逻辑）：
   *  - 内存命中 → 跳过
   *  - 磁盘缓存命中 → 加载 JPG
   *  - 否则 → native 解码 → 存 JPG
   */
  private async ensureDecoded(pageNum: number): Promise<void> {
    if (pageNum < 0 || pageNum >= this.pageCount) {
      return;
    }
    if (this.pageReady[pageNum] || this.inFlight.has(pageNum)) {
      return;
    }
    this.inFlight.add(pageNum);
    try {
      if (this.pageBitmaps[pageNum]) {
        this.pageReady[pageNum] = true;
        return;
      }
      const cachedPath = this.paths[pageNum];
      // 磁盘缓存命中：从 JPG 加载（避免重复 native 解码）
      if (cachedPath && FileUtil.exists(cachedPath)) {
        const pm = await this.loadJpeg(cachedPath);
        if (pm) {
          this.pageBitmaps[pageNum] = pm;
          this.pageReady[pageNum] = true;
          return;
        }
      }
      // native 解码
      const r = await this.decodeService.decodePage(pageNum, this.containerWidth);
      const pm = await image.createPixelMap(r.buffer, {
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        size: { width: r.width, height: r.height },
        editable: false,
      } as image.InitializationOptions);
      // 缓存到磁盘与内存
      try {
        await FileUtil.saveImage(cachedPath, pm, this.imgDir);
      } catch (e) {
        console.warn(`${TAG} saveImage fail: ${e}`);
      }
      this.pageBitmaps[pageNum] = pm;
      this.pageReady[pageNum] = true;
    } catch (e) {
      console.error(`${TAG} ensureDecoded(${pageNum}) fail: ${e}`);
    } finally {
      this.inFlight.delete(pageNum);
    }
  }

  private async loadJpeg(path: string): Promise<PixelMap | undefined> {
    try {
      const src = image.createImageSource(path);
      const pm = await src.createPixelMap({
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
        desiredSize: { width: 0, height: 0 },
        editable: false,
      } as image.DecodingOptions);
      return pm;
    } catch (e) {
      console.warn(`${TAG} loadJpeg fail: ${e}`);
      return undefined;
    }
  }

  private onPageChange(index: number) {
    this.currentIndex = index;
    // 当前页与下一页预解码
    this.ensureDecoded(index);
    this.ensureDecoded(index + 1);
  }

  @Builder
  PageBuilder(index: number) {
    Stack() {
      if (this.pageBitmaps[index]) {
        Image(this.pageBitmaps[index])
          .objectFit(ImageFit.Contain)
          .width('100%')
          .height('100%');
      } else if (this.pageReady[index] && this.paths[index]) {
        Image('file://' + this.paths[index])
          .objectFit(ImageFit.Contain)
          .width('100%')
          .height('100%');
      } else {
        Column() {
          LoadingProgress().width(40).height(40).color(Color.Gray);
          Text('加载中')
            .fontSize(14)
            .fontColor(Color.Gray)
            .margin({ top: 8 });
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black);
  }

  build() {
    Column() {
      // 顶部工具栏（对应 Android Toolbar）
      Stack({ alignContent: Alignment.Start }) {
        Row() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .margin({ left: 12 })
            .onClick(() => this.getUIContext().getRouter().back());
          Text(this.title)
            .fontSize(18)
            .fontColor(RenderConst.TITLE_COLOR)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: 8 });
        }
        .alignItems(VerticalAlign.Center)
        .height('100%');
      }
      .width('100%')
      .height(RenderConst.TOOLBAR_HEIGHT)
      .backgroundColor(RenderConst.TOOLBAR_BG);

      // 内容区（对应 Android FrameLayout）
      Stack() {
        if (this.pageCount > 0 && !this.hasError) {
          Swiper() {
            ForEach(this.pageReady, (ready: boolean, index: number) => {
              this.PageBuilder(index);
            }, (_ready: boolean, index: number) => index.toString())
          }
          .index(this.currentIndex)
          .indicator(true)
          .loop(false)
          .width('100%')
          .height('100%')
          .onChange((index: number) => this.onPageChange(index));
        } else if (this.hasError) {
          Column() {
            Text('加载失败')
              .fontSize(16)
              .fontColor(Color.Gray);
            Text(this.errorMsg)
              .fontSize(12)
              .fontColor(Color.Gray)
              .margin({ top: 8, left: 16, right: 16 })
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center);
        }

        // 加载层（对应 Android ProgressDialog）
        if (this.isLoading) {
          Column() {
            LoadingProgress().width(48).height(48).color(Color.White);
            Text('正在努力加载')
              .fontSize(14)
              .fontColor(Color.White)
              .margin({ top: 12 });
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#88000000');
        }
      }
      .layoutWeight(1)
      .backgroundColor(Color.Black);

      // 底部页码指示（对应 Android PagerTabStrip "第N页"）
      if (this.pageCount > 0 && !this.isLoading) {
        Text(`第 ${this.currentIndex + 1} / ${this.pageCount} 页`)
          .fontSize(17)
          .fontColor('#FF666666')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 6, bottom: 6 })
          .backgroundColor('#FFF5F5F5');
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black);
  }
}
