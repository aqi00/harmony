import { BusinessError } from '@ohos.base';
import { fileIo, picker } from '@kit.CoreFileKit';
import { webview } from '@kit.ArkWeb';
import { common } from '@kit.AbilityKit';
import { DocxParser, ParseResult } from '../docx/DocxParser';
import { DocxExtractor } from '../docx/DocxExtractor';
import { TxtUtils } from '../docx/TxtUtils';
import { FileUtil } from '../docx/FileUtil';

/** 内置样例：文本 DOCX（纯文本） */
//const SAMPLE_TEXT_DOCX = 'xiguan.docx';
const SAMPLE_TEXT_DOCX = 'kunming.docx';
/** 内置样例：图文 DOCX（带图片） */
const SAMPLE_IMAGE_DOCX = 'jiaju.docx';

/**
 * ArkUI 主页面 —— 替代 Android MainActivity + activity_main.xml。
 */
@Entry
@Component
struct DocxReaderPage {

  // ---------- UI 状态 ----------
  @State filePath: string = '';
  @State lang: string = '';
  @State isLoading: boolean = false;
  @State baseUrl: string = '';
  @State htmlContent: string = DocxApp.buildWelcomeHtml();

  // ---------- Web 控制器 ----------
  private webController: webview.WebviewController = new webview.WebviewController();

  // ---------- 上下文（aboutToAppear 里拿到后设置） ----------
  private ctx: common.UIAbilityContext | null = null;
  /** 样例 docx 所在目录（resfile 只读，直接用 fileIo 读，无需拷贝到沙箱） */
  private sampleDir: string = '';
  /** picker 选中文档的存放目录（可写） */
  private pickerDir: string = '';
  /** 解析产物（HTML + 图片）输出目录 */
  private outDir: string = '';
  private imagesDir: string = '';

  aboutToAppear(): void {
    try {
      this.ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
      if (this.ctx) {
        // resfile 目录在 resourceDir 下，只读，可直接 fileIo.openSync 读取
        this.sampleDir = this.ctx.resourceDir;
        this.pickerDir = this.ctx.cacheDir + '/picker';
        this.outDir = this.ctx.filesDir + '/docx';
        this.imagesDir = this.ctx.cacheDir + '/docx_images';
        FileUtil.ensureDir(this.pickerDir);
        FileUtil.ensureDir(this.outDir);
        FileUtil.ensureDir(this.imagesDir);
        console.info('Index.sampleDir =', this.sampleDir);
        fileIo.copyFileSync(`${this.sampleDir}/${SAMPLE_TEXT_DOCX}`, `${this.outDir}/${SAMPLE_TEXT_DOCX}`);
        fileIo.copyFileSync(`${this.sampleDir}/${SAMPLE_IMAGE_DOCX}`, `${this.outDir}/${SAMPLE_IMAGE_DOCX}`);
      }
    } catch (e) {
      console.info('Index.aboutToAppear failed', String(e));
    }
  }

  // ============================================================
  // 文件选择（替代 Android ActivityResultLauncher）
  // ============================================================
  private chooseDocument(): void {
    if (!this.ctx) return;
    const options = new picker.DocumentSelectOptions();
    options.maxSelectNumber = 1;
    options.fileSuffixFilters = ['.docx'];
    const pv = new picker.DocumentViewPicker(this.ctx);
    pv.select(options).then((uris: Array<string>) => {
      if (uris.length === 0) {
        console.info('documentPicker.select 请选择文件');
        return;
      }
      console.info('documentPicker.select ok', uris);
      this.openSample(uris[0]);
    }).catch((err: BusinessError) => {
      console.info('documentPicker.select failed', JSON.stringify(err));
    });
  }

  // ============================================================
  // 核心解析入口
  // ============================================================
  private openSample(pathOrUri: string): void {
    if (!pathOrUri) return;

    this.filePath = DocxApp.fileNameFromPath(pathOrUri);
    this.baseUrl = 'file://' + this.imagesDir
    this.isLoading = true;
    this.htmlContent = '<html><body style="padding:24px">Parsing docx, please wait...</body></html>';

    setTimeout(async () => {
      try {
        // 如果是 picker 返回的 content:// URI，先用 FileUtil 读成字节存到可写沙箱路径
        let docxPath = pathOrUri;

        const langCode = await DocxExtractor.getLang(docxPath);
        const result: ParseResult = await DocxParser.convertToHtml(docxPath, this.imagesDir);

        this.lang = TxtUtils.isEmpty(langCode) ? 'not detected' : langCode;

        if (!result.success) {
          this.htmlContent = '<html><body style="padding:24px;color:red">Parse failed: ' +
            result.error + '</body></html>';
        } else {
          this.htmlContent = DocxApp.wrapHtml(result.html);
        }
      } catch (e) {
        console.info('openSample failed', String(e));
        this.htmlContent = '<html><body style="padding:24px;color:red">Error: ' + String(e) + '</body></html>';
      } finally {
        // 先 loadData，再把 isLoading 置 false —— 避免 @State 触发 Web 重建覆盖掉刚加载的内容
        try {
          // loadData 第 4 个参数是 baseUrl，img 标签里的 file:// 相对路径需要它
          this.webController.loadData(this.htmlContent, 'text/html', 'utf-8', this.baseUrl);
          console.info('loadData ok, htmlLen=', this.htmlContent.length, ' baseUrl=', this.baseUrl);
        } catch (_e) {
          console.info('loadData failed', String(_e));
        }
        this.isLoading = false;
      }
    }, 50);
  }

  // ============================================================
  // UI 布局
  // ============================================================

  build() {
    Column() {
      // 三按钮行
      Row({ space: 5 }) {
        Button('打开文件')
          .fontSize(17)
          //.enabled(!this.isLoading)
          .layoutWeight(1)
          .onClick(() => this.chooseDocument())

        Button('文本WORD')
          .fontSize(17)
          //.enabled(!this.isLoading)
          .layoutWeight(1)
          .onClick(() => this.openSample(this.outDir + '/' + SAMPLE_TEXT_DOCX))

        Button('图文WORD')
          .fontSize(17)
          //.enabled(!this.isLoading)
          .layoutWeight(1)
          .onClick(() => this.openSample(this.outDir + '/' + SAMPLE_IMAGE_DOCX))
      }
      .margin(5) // 如果设置了.width('100%')，那么水平方向的margin就不会奏效

      // Web 渲染区
      Web({ src: '', controller: this.webController })
        .width('100%')
        .layoutWeight(1)
        .margin({ bottom: 10 })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .zoomAccess(true)
        .fileAccess(true)
        .cacheMode(CacheMode.None)
        .onControllerAttached(() => {
          this.webController.loadData(this.htmlContent, 'text/html', 'utf-8');
        })
    }
    .width('100%')
    .height('100%')
  }
}

/** 工具辅助类。 */
class DocxApp {
  static buildWelcomeHtml(): string {
    return '<html><body style="padding:24px;font-family:sans-serif;color:#888;">' +
      '<h2 style="color:#333">DocxApp</h2>' +
      '<p>Click a button above to load a .docx file.</p>' +
      '<ul>' +
      '<li><b>打开文件</b> - 从存储选择任意 .docx</li>' +
      '<li><b>文本WORD</b> - 样例: xiguan.docx (text only)</li>' +
      '<li><b>图文WORD</b> - 样例: jiaju.docx (with images)</li>' +
      '</ul>' +
      '<p style="margin-top:24px;font-size:12px">ArkTS native port from Android docxtest</p>' +
      '</body></html>';
  }

  static wrapHtml(bodyHtml: string): string {
    return '<!DOCTYPE html><html><head>' +
      '<meta charset="utf-8">' +
      '<meta name="viewport" content="width=device-width,initial-scale=1">' +
      '<style>' +
      'body{font-family:sans-serif;line-height:1.7;padding:16px;color:#222;background:#fff}' +
      'img{max-width:100%;height:auto}' +
      'p{margin:0 0 1em 0}' +
      'h1,h2,h3,h4,h5,h6{margin:0.5em 0}' +
      '</style></head><body>' +
      bodyHtml +
      '</body></html>';
  }

  static fileNameFromPath(p: string): string {
    const idx = Math.max(p.lastIndexOf('/'), p.lastIndexOf('\\'));
    return idx >= 0 ? p.substring(idx + 1) : p;
  }
}
