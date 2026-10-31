/**
 * CHM 阅读界面（迁移自 ChmApp，对应 Android MainActivity + ReaderActivity + 两个布局文件）。
 * 依赖 HAR 模块 chm（解析内核 + NAPI + ArkTS 封装）。
 */
import common from '@ohos.app.ability.common';
import { preferences } from '@kit.ArkData';
import { picker } from '@kit.CoreFileKit';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

import {
  ChmFile,
  ChmPath,
  ChmSystem,
  ChmToc,
  ChmWebViewClient,
  LoadDecision,
  FileUtil,
  TocItem
} from 'chm';

const TAG = 'ChmReaderPage';
const PREF_NAME = 'chm_reader';
const KEY_ZOOM = 'font_zoom';
const KEY_LAST_PAGE = 'last_page';

/** 字号档位。 */
const ZOOM_STEPS: number[] = [80, 100, 125, 150, 175, 200];

/** 内置样例（resfile 目录） */
const SAMPLE_TEXT_CHM = 'mmc.chm';
const SAMPLE_IMAGE_CHM = 'wpsapi.chm';

const BRAND = '#0F766E';
const PAGE_BG = '#FAFAF7';
const BAR_BG = '#F1F5F4';
const TEXT_PRIMARY = '#1F2937';
const TEXT_SECONDARY = '#6B7280';
const DIVIDER = '#E5E7EB';

@Entry
@Component
struct ChmReaderPage {
  @State title: string = 'CHM 阅读器';
  @State tocItems: TocItem[] = [];
  @State tocVisible: boolean = false;
  @State loading: boolean = false;
  @State errorMsg: string = '';
  @State pageInfoText: string = '';
  @State progress: number = 0;
  @State hasBook: boolean = false;
  @State fontZoom: number = 100;

  private controller: webview.WebviewController = new webview.WebviewController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private file: ChmFile | null = null;
  private client: ChmWebViewClient | null = null;
  private pages: string[] = [];
  private currentPath: string = '';
  private bookPath: string = '';
  private prefs: preferences.Preferences | null = null;
  private tocScroller: Scroller = new Scroller();
  private sampleDir: string = '';

  aboutToAppear(): void {
    this.bookPath = `${this.context.filesDir}/books/current.chm`;
    this.sampleDir = this.context.resourceDir;
    FileUtil.ensureDir(`${this.context.filesDir}/books`);
  }

  private onWebReady(): void {
    const options: preferences.Options = { name: PREF_NAME };
    preferences.getPreferences(this.context, options)
      .then((prefs: preferences.Preferences) => {
        this.prefs = prefs;
        const zoom = prefs.getSync(KEY_ZOOM, 100);
        if (typeof zoom === 'number') {
          this.fontZoom = zoom;
        }
        this.startReading();
      })
      .catch((err: BusinessError) => {
        console.error(`${TAG} load preferences fail: ${err.message}`);
        this.startReading();
      });
  }

  private startReading(): void {
    if (FileUtil.isFile(this.bookPath)) {
      this.openChm(this.bookPath, 'current.chm');
    } else {
      this.showWelcome();
    }
  }

  private openChm(path: string, displayName: string): void {
    this.loading = true;
    this.errorMsg = '';
    this.progress = 0;
    try {
      this.closeBook();
      const file = ChmFile.open(path);
      const system = ChmSystem.open(file);
      const toc = ChmToc.build(file, system);
      this.file = file;
      this.pages = toc.pages;
      this.tocItems = toc.items;
      const client = new ChmWebViewClient(file, system);
      client.onOpenExternal = (url: string) => {
        this.toast(`已拦截外部链接：${url}`);
      };
      client.onMissingPage = (page: string) => {
        this.toast(`页面不存在：${page}`);
      };
      client.onPageLoaded = (page: string) => {
        this.currentPath = page;
        this.updatePageInfo();
        this.savePage(page);
        this.applyZoom();
      };
      this.client = client;

      const bookTitle = system.getTitle();
      this.title = bookTitle !== '' ? bookTitle : displayName;
      this.hasBook = this.pages.length > 0;

      let start = toc.defaultPage;
      const saved = this.readSavedPage();
      if (saved !== '' && file.hasFile(ChmPath.stripQueryAndFragment(saved))) {
        start = saved;
      }
      if (start === '') {
        this.loading = false;
        this.showWelcome();
        this.toast('未找到可阅读的 HTML 页面');
        return;
      }
      this.currentPath = ChmPath.normalize(ChmPath.stripQueryAndFragment(start));
      this.controller.loadUrl(ChmWebViewClient.buildUrl(start));
    } catch (err) {
      this.loading = false;
      this.hasBook = false;
      this.errorMsg = `打开失败：${(err as Error).message}`;
      console.error(`${TAG} openChm fail: ${(err as Error).message}`);
      this.showWelcome();
    }
  }

  private closeBook(): void {
    this.client = null;
    if (this.file !== null) {
      this.file.close();
      this.file = null;
    }
    this.pages = [];
    this.tocItems = [];
    this.currentPath = '';
    this.pageInfoText = '';
  }

  private async chooseBook(): Promise<void> {
    try {
      const options = new picker.DocumentSelectOptions();
      options.maxSelectNumber = 1;
      options.fileSuffixFilters = ['.chm'];
      const documentPicker = new picker.DocumentViewPicker(this.context);
      const uris: string[] = await documentPicker.select(options);
      if (uris.length === 0) {
        return;
      }
      const uri = uris[0];
      this.loading = true;
      this.toast('正在导入文件…');
      FileUtil.ensureDir(`${this.context.filesDir}/books`);
      FileUtil.copyToFile(uri, this.bookPath);
      this.openChm(this.bookPath, this.displayNameOf(uri));
    } catch (err) {
      this.loading = false;
      this.errorMsg = `打开失败：${(err as Error).message}`;
      console.error(`${TAG} chooseBook fail: ${(err as Error).message}`);
    }
  }

  private openSample(name: string): void {
    const path = `${this.sampleDir}/${name}`;
    console.info(`${TAG} openSample path: ${path}`);
    if (!FileUtil.isFile(path)) {
      this.toast(`${name} 不存在`);
      return;
    }
    this.openChm(path, name);
  }

  private displayNameOf(uri: string): string {
    let name = FileUtil.baseName(uri);
    const query = name.indexOf('?');
    if (query >= 0) {
      name = name.substring(0, query);
    }
    try {
      return decodeURIComponent(name);
    } catch (err) {
      console.error(`${TAG} decode name fail: ${(err as Error).message}`);
      return name;
    }
  }

  private showWelcome(): void {
    this.hasBook = false;
    this.pageInfoText = '';
    this.tocItems = [];
    const html = '<!DOCTYPE html><html lang="zh-CN"><head><meta charset="utf-8">'
      + '<meta name="viewport" content="width=device-width, initial-scale=1">'
      + '<style>body{margin:0;padding:32px 24px;background:' + PAGE_BG + ';color:' + TEXT_PRIMARY + ';'
      + 'font-family:system-ui,-apple-system,"HarmonyOS Sans SC",sans-serif;line-height:1.7;}'
      + 'h1{font-size:22px;margin:0 0 12px;color:' + BRAND + ';}'
      + '.slogan{font-size:14px;color:' + TEXT_SECONDARY + ';margin:0 0 24px;}'
      + '.tip{font-size:14px;margin:0 0 10px;}'
      + 'ul{font-size:14px;color:' + TEXT_SECONDARY + ';padding-left:20px;margin:0;}'
      + 'li{margin-bottom:6px;}</style></head><body>'
      + '<h1>CHM 阅读器</h1>'
      + '<p class="slogan">CHM 解析内核抽取自 CoolReader（chmlib + chmfmt），支持目录、编码识别、图文与样式阅读。</p>'
      + '<p class="tip">点击顶部「打开CHM文件」选择 .chm 文档，也可直接体验内置样例。</p>'
      + '<ul><li>「文本CHM」/「图文CHM」打开工程内置样例</li><li>「目录」切换章节</li><li>「字号」循环调整文字大小</li>'
      + '<li>页面内的相对链接、图片、CSS 会从 CHM 中自动读取</li>'
      + '<li>底部可上一页 / 下一页顺序阅读</li></ul>'
      + '</body></html>';
    this.controller.loadData(html, 'text/html', 'UTF-8');
  }

  private toast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`${TAG} toast fail: ${(err as Error).message}`);
    }
  }

  private applyZoom(): void {
    if (!this.hasBook) {
      return;
    }
    const scale = (this.fontZoom / 100).toFixed(2);
    const script = `document.body.style.zoom='${scale}';void 0;`;
    this.controller.runJavaScript(script).catch((err: BusinessError) => {
      console.error(`${TAG} applyZoom fail: ${err.message}`);
    });
  }

  private cycleZoom(): void {
    let index = ZOOM_STEPS.indexOf(this.fontZoom);
    if (index < 0) {
      index = ZOOM_STEPS.indexOf(100);
    }
    this.fontZoom = ZOOM_STEPS[(index + 1) % ZOOM_STEPS.length];
    if (this.prefs !== null) {
      this.prefs.putSync(KEY_ZOOM, this.fontZoom);
      this.prefs.flush().catch((err: BusinessError) => {
        console.error(`${TAG} save zoom fail: ${err.message}`);
      });
    }
    this.applyZoom();
    this.toast(`字号 ${this.fontZoom}%`);
  }

  private readSavedPage(): string {
    if (this.prefs === null) {
      return '';
    }
    const value = this.prefs.getSync(KEY_LAST_PAGE, '');
    return typeof value === 'string' ? value : '';
  }

  private savePage(page: string): void {
    if (this.prefs === null || page === '') {
      return;
    }
    this.prefs.putSync(KEY_LAST_PAGE, page);
    this.prefs.flush().catch((err: BusinessError) => {
      console.error(`${TAG} save page fail: ${err.message}`);
    });
  }

  private pageIndexOf(path: string): number {
    const target = ChmPath.normalize(ChmPath.stripQueryAndFragment(path));
    return this.pages.indexOf(target);
  }

  private updatePageInfo(): void {
    if (this.pages.length === 0) {
      this.pageInfoText = '';
      return;
    }
    const index = this.pageIndexOf(this.currentPath);
    this.pageInfoText = index >= 0 ? `${index + 1} / ${this.pages.length}` : `— / ${this.pages.length}`;
  }

  private goPage(step: number): void {
    if (this.pages.length === 0) {
      return;
    }
    const index = this.pageIndexOf(this.currentPath);
    if (index < 0) {
      this.toast('未找到当前页位置');
      return;
    }
    const next = index + step;
    if (next < 0) {
      this.toast('已经是第一页');
      return;
    }
    if (next >= this.pages.length) {
      this.toast('已经是最后一页');
      return;
    }
    this.controller.loadUrl(ChmWebViewClient.buildUrl(this.pages[next]));
  }

  private openTocItem(item: TocItem): void {
    this.tocVisible = false;
    if (!item.hasUrl()) {
      return;
    }
    this.controller.loadUrl(ChmWebViewClient.buildUrl(item.url));
  }

  private interceptRequest(event: OnInterceptRequestEvent): WebResourceResponse | null {
    const url = event.request.getRequestUrl();
    if (this.client === null || !ChmWebViewClient.isInternalUrl(url)) {
      return null;
    }
    return this.client.handleRequest(url, event.request.isMainFrame());
  }

  private interceptLoad(event: OnLoadInterceptEvent): boolean {
    const url = event.data.getRequestUrl();
    if (this.client === null) {
      return false;
    }
    const decision: LoadDecision = this.client.handleLoad(url);
    if (decision.redirect !== '') {
      this.controller.loadUrl(decision.redirect);
    }
    return decision.intercept;
  }

  onBackPress(): boolean {
    if (this.tocVisible) {
      this.tocVisible = false;
      return true;
    }
    if (!this.hasBook) {
      return false;
    }
    if (this.controller.accessBackward()) {
      this.controller.backward();
      return true;
    }
    return false;
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Button('打开CHM文件')
          .fontSize(13)
          .layoutWeight(1)
          .height(34)
          .backgroundColor(BRAND)
          .fontColor(Color.White)
          .onClick(() => {
            this.chooseBook();
          });
        Button('文本CHM')
          .fontSize(13)
          .layoutWeight(1)
          .height(34)
          .backgroundColor('#FFFFFF')
          .fontColor(TEXT_PRIMARY)
          .onClick(() => this.openSample(SAMPLE_TEXT_CHM));
        Button('图文CHM')
          .fontSize(13)
          .layoutWeight(1)
          .height(34)
          .backgroundColor('#FFFFFF')
          .fontColor(TEXT_PRIMARY)
          .onClick(() => this.openSample(SAMPLE_IMAGE_CHM));
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 4 })
      .backgroundColor(BAR_BG);

      Row({ space: 8 }) {
        Button('目录')
          .fontSize(13)
          .layoutWeight(1)
          .height(34)
          .backgroundColor(this.tocVisible ? BRAND : '#FFFFFF')
          .fontColor(this.tocVisible ? Color.White : TEXT_PRIMARY)
          .enabled(this.hasBook)
          .onClick(() => {
            this.tocVisible = !this.tocVisible;
          });
        Button(`字号 ${this.fontZoom}%`)
          .fontSize(13)
          .layoutWeight(1)
          .height(34)
          .backgroundColor('#FFFFFF')
          .fontColor(TEXT_PRIMARY)
          .onClick(() => {
            this.cycleZoom();
          });
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 4, bottom: 8 })
      .backgroundColor(BAR_BG);

      if (this.loading) {
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(2)
          .color(BRAND);
      }

      if (this.errorMsg !== '') {
        Text(this.errorMsg)
          .width('100%')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .fontSize(12)
          .fontColor('#B91C1C')
          .backgroundColor('#FEF2F2');
      }

      Stack({ alignContent: Alignment.TopStart }) {
        Web({ src: '', controller: this.controller })
          .width('100%')
          .height('100%')
          .backgroundColor(PAGE_BG)
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .zoomAccess(true)
          .onControllerAttached(() => {
            this.onWebReady();
          })
          .onInterceptRequest((event: OnInterceptRequestEvent) => {
            return this.interceptRequest(event) as WebResourceResponse;
          })
          .onLoadIntercept((event: OnLoadInterceptEvent) => {
            return this.interceptLoad(event);
          })
          .onPageEnd((event: OnPageEndEvent) => {
            this.loading = false;
            this.progress = 100;
            if (this.client !== null) {
              this.client.handlePageFinished(event.url);
            }
          })
          .onProgressChange((event: OnProgressChangeEvent) => {
            this.progress = event.newProgress;
          });

        if (this.tocVisible) {
          Column() {
            Row() {
              Text('目录')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(TEXT_PRIMARY)
                .layoutWeight(1);
              Button('关闭')
                .fontSize(12)
                .height(28)
                .backgroundColor(Color.Transparent)
                .fontColor(BRAND)
                .onClick(() => {
                  this.tocVisible = false;
                });
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 8 });

            Text(this.title)
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 8 })
              .fontSize(12)
              .fontColor(TEXT_SECONDARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });

            Divider().color(DIVIDER);

            if (this.tocItems.length === 0) {
              Column() {
                Text('该 CHM 没有可用目录')
                  .fontSize(13)
                  .fontColor(TEXT_SECONDARY);
              }
              .width('100%')
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center);
            } else {
              List({ space: 0, scroller: this.tocScroller }) {
                ForEach(this.tocItems, (item: TocItem, index: number) => {
                  ListItem() {
                    Text(item.title)
                      .width('100%')
                      .fontSize(14)
                      .fontColor(TEXT_PRIMARY)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .padding({
                        left: 16 + item.level * 14,
                        right: 12,
                        top: 12,
                        bottom: 12
                      });
                  }
                  .onClick(() => {
                    this.openTocItem(item);
                  });
                }, (item: TocItem, index: number) => `${index}_${item.url}`);
              }
              .width('100%')
              .layoutWeight(1)
              .divider({ strokeWidth: 1, color: DIVIDER });
            }
          }
          .width('80%')
          .height('100%')
          .backgroundColor(Color.White)
          .shadow({ radius: 8, color: '#33000000', offsetX: 3, offsetY: 0 });
        }
      }
      .width('100%')
      .layoutWeight(1);

      if (this.hasBook) {
        Row() {
          Button('上一页')
            .fontSize(13)
            .height(36)
            .backgroundColor(Color.Transparent)
            .fontColor(TEXT_PRIMARY)
            .onClick(() => {
              this.goPage(-1);
            });
          Text(this.pageInfoText)
            .fontSize(13)
            .fontColor(TEXT_SECONDARY)
            .layoutWeight(1)
            .textAlign(TextAlign.Center);
          Button('下一页')
            .fontSize(13)
            .height(36)
            .backgroundColor(Color.Transparent)
            .fontColor(TEXT_PRIMARY)
            .onClick(() => {
              this.goPage(1);
            });
        }
        .width('100%')
        .height(48)
        .padding({ left: 8, right: 8 })
        .backgroundColor(BAR_BG);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BG);
  }
}
