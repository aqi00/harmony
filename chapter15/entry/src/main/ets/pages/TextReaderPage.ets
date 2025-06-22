import { TextReader, TextReaderIcon, ReadStateCode } from '@kit.SpeechKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct TextReaderPage {
  context = this.getUIContext().getHostContext() as common.Context;
  @State readInfoList: TextReader.ReadInfo[] = []; // 待朗读的文章列表
  @State selectedReadInfo: TextReader.ReadInfo = this.readInfoList[0];
  @State readState: ReadStateCode = ReadStateCode.WAITING; // 朗读状态

  aboutToAppear(){
    this.readInfoList = [{ id: '001', // 文章编号
      title: { text: '水调歌头·明月几时有', isClickable: true }, // 文章标题
      author: { text: '宋·苏轼', isClickable: true }, // 文章作者
      date: { text: '2025/01/01', isClickable: false }, // 日期
      bodyInfo: '明月几时有？把酒问青天。\n\n不知天上宫阙，今夕是何年。\n\n'
    }];
    this.selectedReadInfo = this.readInfoList[0] // 默认选中的文章
    this.initTextReader() // 初始化文本朗读器
  }

  // 初始化文本朗读器
  initTextReader() {
    const readerParam: TextReader.ReaderParam = {
      isVoiceBrandVisible: true, // 是否显示播报品牌
      businessBrandInfo: {
        panelName: '小艺朗读', // 品牌名称
        panelIcon: $r('app.media.startIcon') // 品牌图标
      }
    }
    TextReader.init(this.context, readerParam) // 初始化文本朗读器
  }

  // 开始朗读文本
  startReadText() {
    if (this.readState === ReadStateCode.PLAYING) {
      TextReader.showPanel() // 已经在播放，显示播放面板
      return;
    }
    // 监听文本朗读的状态变更事件
    TextReader.on('stateChange', (state: TextReader.ReadState) => {
      console.info(`ReadState: %{public}s`, JSON.stringify(state));
      console.info(`selectedReadInfo.id: %{public}s`, this.selectedReadInfo?.id);
      if (this.selectedReadInfo?.id === state.id) {
        console.info(`match, changeState to %{public}s`, JSON.stringify(state))
        this.readState = state.state // 更新当前的朗读状态
      } else {
        this.readState = ReadStateCode.WAITING
      }
    });
    TextReader.start(this.readInfoList, this.selectedReadInfo?.id) // 开始朗读
  }

  build() {
    Column() {
      TextReaderIcon({ readState: this.readState }).width(32).height(32)
        .onClick( () => {
          this.startReadText() // 开始朗读文本
        })
      Text(this.readState === ReadStateCode.PLAYING ? '正在播放' : '开始播放').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }

}