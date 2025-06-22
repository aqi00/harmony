import { AICaptionComponent, AICaptionOptions, AICaptionController, AudioData } from '@kit.SpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct IntellectCaptionPage {
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext() as common.Context;
  private resMgr = this.context.resourceManager; // 资源管理器
  @State isShown: boolean = true; // 是否显示字幕
  private controller: AICaptionController = new AICaptionController();
  private captionOption?: AICaptionOptions; // 字幕初始化参数
  private pcmFile: string = 'night.pcm'; // 待识别的音频文件
  private isRecognizing: boolean = false; // 是否正在识别

  aboutToAppear() {
    // AI字幕初始化参数，设置字幕的不透明度
    this.captionOption = {
      initialOpacity: 1, // 字幕精简态下面板背景的不透明度
      onPrepared: () => { // 控件初始化完成的回调函数
        console.info('onPrepared')
      },
      onError: (error: BusinessError) => { // 控件错误的回调函数
        console.error(`AICaption component error. Error code: ${error.code}, message: ${error.message}`)
        this.promptAction.showToast({ message: `AICaptionComponent初始化失败：${error.code}`})
      }
    }
  }

  // 读取音频流
  async readPcmAudio() {
    let fileData = this.resMgr.getRawFileContentSync(this.pcmFile);
    this.isRecognizing = true;
    const bufferSize = 640;
    const byteLength = fileData.byteLength;
    let offset = 0;
    console.info(`Pcm data total bytes: ${byteLength.toString()}`)
    let startTime = new Date().getTime();
    while (offset < byteLength) {
      // 模拟实际情况，读文件比录音机返回流快，所以要等待一段时间
      let nextOffset = offset + bufferSize
      if (offset > byteLength) {
        this.isRecognizing = false;
        return
      }
      const arrayBuffer = fileData.buffer.slice(offset, nextOffset);
      let data = new Uint8Array(arrayBuffer);
      const audioData: AudioData = {
        data: data
      }

      if (this.controller) {
        this.controller.writeAudio(audioData)
      }
      offset = offset + bufferSize;
      const waitTime = bufferSize / 32
      await this.sleep(waitTime)
    }
    let endTime = new Date().getTime()
    this.isRecognizing = false;
    console.info(`Audio play time: ${JSON.stringify(endTime - startTime)}`)
  }

  sleep(time: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, time))
  }

  build() {
    Column() {
      Button('读取音频文件').width('100%').fontSize(18)
        .onClick(() => {
          if (!this.isRecognizing) {
            this.readPcmAudio() // 读取音频流
          }
        })
      // 调用AICaptionComponent组件初始化字幕。
      // 真机验证结果：Mate60pro可以正常使用AICaptionComponent组件，nova12pro不能初始化AICaptionComponent组件
      // 提示：“AICaption component error. Error code: 1010600011, message: AICaption controller init failed.”
      // 根据官网的构造方法介绍，部分机型暂不支持该组件，包括nova 12/nova 12 Pro/nova 13/nova 13 Pro/nova 14
      // https://developer.huawei.com/consumer/cn/doc/harmonyos-references/speech-aicaptioncomponent
      AICaptionComponent({ isShown: this.isShown, controller: this.controller,
        options: this.captionOption }).width('80%').height(100)
    }
    .width('100%').height('100%')
  }
}