/**
 * RTF 阅读界面（对应 Android MainActivity + activity_main.xml）。
 *
 * 布局：标题栏 + 【打开文件】【文本RTF】【图文RTF】按钮栏 + ArkWeb 内容区。
 * 解析链路由 RtfExtract（RTF → HTML，图片内联 base64）驱动，渲染交给 ArkWeb。
 */
import common from '@ohos.app.ability.common';
import { picker } from '@kit.CoreFileKit';
import { webview } from '@kit.ArkWeb';

import { FileUtil } from '../rtf/FileUtil';
import { RtfExtract } from '../rtf/RtfExtract';

const TAG = 'RtfIndex';

/** 内置样例：文本 RTF */
const SAMPLE_TEXT_RTF = 'QQLicense.rtf';
/** 内置样例：图文 RTF */
const SAMPLE_IMAGE_RTF = 'kuaipan.rtf';
const SAMPLE_FILES: string[] = [SAMPLE_TEXT_RTF, SAMPLE_IMAGE_RTF];

/** 生成的 HTML 文件名（对齐 Android RtfExtract.extract 的 "index.html"）。 */
const HTML_NAME = 'index.html';

@Entry
@Component
struct RtfReaderPage {
  @State title: string = 'RtfReader';
  private controller: webview.WebviewController = new webview.WebviewController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  /** 样例 RTF 所在的沙箱目录 */
  private sampleDir: string = '';
  /** 解析产物（HTML + 图片）输出目录 */
  private outDir: string = '';

  aboutToAppear(): void {
    this.sampleDir = this.context.resourceDir;
    this.outDir = `${this.context.filesDir}/rtf`;
    FileUtil.ensureDir(this.outDir);
  }

  /** 点击【文本RTF】/【图文RTF】：解析沙箱目录下的样例文件。 */
  private openSample(name: string): void {
    const path = `${this.sampleDir}/${name}`;
    console.info(`${TAG} openSample path: ${path}`);
    if (!FileUtil.exists(path)) {
      this.toast(`${name} 不存在`);
      return;
    }
    this.title = name;
    try {
      const result = RtfExtract.extract(path, this.outDir, HTML_NAME);
      this.controller.loadData(result.html, 'text/html', 'UTF-8');
    } catch (e) {
      console.error(`${TAG} openSample fail: ${e}`);
      this.toast(`解析失败: ${e}`);
    }
  }

  /** 点击【打开文件】：从外部选择 RTF 并解析。 */
  private async openFile(): Promise<void> {
    try {
      const options = new picker.DocumentSelectOptions();
      options.maxSelectNumber = 1;
      options.fileSuffixFilters = ['.rtf'];
      const documentPicker = new picker.DocumentViewPicker(this.context);
      const uris: string[] = await documentPicker.select(options);
      if (uris.length === 0) {
        return;
      }
      const uri = uris[0];
      this.title = FileUtil.baseName(uri);
      const result = RtfExtract.extractBytes(FileUtil.readBytesByUri(uri), this.outDir, HTML_NAME);
      this.controller.loadData(result.html, 'text/html', 'UTF-8');
      console.info(`${TAG} html path: ${result.htmlPath}`);
    } catch (e) {
      console.error(`${TAG} openFile fail: ${e}`);
      this.toast(`打开文件失败: ${e}`);
    }
  }

  private toast(msg: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: msg, duration: 2000 });
    } catch (e) {
      console.error(`${TAG} toast fail: ${e}`);
    }
  }

  build() {
    Column() {
      // 按钮栏（对应 activity_main.xml 的 buttonOpen / buttonTextRtf / buttonImageRtf）
      Row({ space: 8 }) {
        Button('打开RTF文件')
          .fontSize(14)
          .onClick(() => {
            this.openFile();
          });
        Button('文本RTF')
          .layoutWeight(1)
          .fontSize(14)
          .onClick(() => this.openSample(SAMPLE_TEXT_RTF));
        Button('图文RTF')
          .layoutWeight(1)
          .fontSize(14)
          .onClick(() => this.openSample(SAMPLE_IMAGE_RTF));
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFF5F5F5');

      // 内容区（对应 Android WebView）
      Web({ src: '', controller: this.controller })
        .width('100%')
        .layoutWeight(1)
        .zoomAccess(true)
        .backgroundColor(Color.White);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White);
  }
}
