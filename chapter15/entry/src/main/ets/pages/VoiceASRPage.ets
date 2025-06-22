import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import AudioCapturer from '../task/AudioCapturer';
import FileCapturer from '../task/FileCapturer';
import { ICapturerInterface } from '../task/ICapturerInterface';

let asrEngine: speechRecognizer.SpeechRecognitionEngine; // ASR引擎实例

@Entry
@Component
struct VoiceASRPage {
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext() as common.Context;
  private resMgr = this.context.resourceManager; // 资源管理器
  @State sessionId: string = '123456'; // 会话编号
  @State generatedText: string = '这里是识别文本';
  private pcmFile1: string = 'night.pcm'; // 夜空日记音频
  private pcmFile2: string = 'spring.pcm'; // 春晓音频
  @State buttonText: string = '开始识别';
  private isRecognizing = false; // 是否正在识别

  private mFileCapturer: ICapturerInterface = new FileCapturer();
  private mAudioCapturer: ICapturerInterface = new AudioCapturer();
  // 设置开始识别的相关参数。目前只支持采样频率16000，单声道，16位
  private audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 };

  // 把目标文件复制到私有目录
  copyFile(fileName: string) {
    console.info('copyFile: '+fileName)
    // 注意：getRawFd方法不能用于复制文件
    let fileData = this.resMgr.getRawFileContentSync(fileName);
    let dstPath = `${this.context.cacheDir}/${fileName}`
    console.info(`dstPath name: ${dstPath}`);
    let dstFile = fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    console.info('end openSync');
    fileIo.writeSync(dstFile.fd, fileData.buffer)
    fileIo.closeSync(dstFile);
  }

  // 创建ASR引擎，通过callback形式返回
  private createAsrEngine() {
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN', // 语种
      online: 1, // 模式。0为在线（暂不支持），1为离线
    };
    // 创建语音识别引擎
    speechRecognizer.createEngine(initParamsInfo).then(speechRecognitionEngine => {
      console.info('speechRecognizer.createEngine is success');
      asrEngine = speechRecognitionEngine // 返回ASR引擎实例
    }).catch((err: BusinessError) => {
      // 无法创建引擎时返回错误码1002200008，原因：引擎正在销毁中
      console.error('speechRecognizer.createEngine: err=' + JSON.stringify(err));
    })
  }

  aboutToAppear() {
    this.createAsrEngine() // 创建ASR引擎
    this.promptAction.showToast({message: '成功创建识别引擎'});
    this.copyFile(this.pcmFile1) // 把pcm文件复制到私有目录
    this.copyFile(this.pcmFile2) // 把pcm文件复制到私有目录
  }

  aboutToDisappear() {
    asrEngine.shutdown() // 关闭ASR引擎
  }

  build() {
    Column() {
      Text(this.generatedText).width('100%').height(80)
        .fontSize(18).padding(5).align(Alignment.Top)
      Row() {
        Button('样本1音频识别').layoutWeight(1).fontSize(18)
          .onClick(() => {
            this.writeAudio(this.pcmFile1) // 写入音频流
          })
        Button('样本2音频识别').layoutWeight(1).fontSize(18)
          .onClick(() => {
            this.writeAudio(this.pcmFile2) // 写入音频流
          })
      }.width('100%')
      Button(this.buttonText).width('100%').fontSize(18).margin({top:5})
        .onClick(async () => {
          if (this.isRecognizing) {
            await this.mFileCapturer.stop();
            asrEngine.finish(this.sessionId) // 结束识别
          } else {
            this.generatedText = ''
            this.startRecording() // 开始录音
            this.promptAction.showToast({message: '开始识别语音，请对话筒说话'});
          }
          this.buttonText = this.isRecognizing ? '开始识别语音' : '停止识别语音'
          this.isRecognizing = !this.isRecognizing
        })
    }
    .width('100%').height('100%')
  }

  // 语音转文本
  private startRecording() {
    this.setListener() // 设置语音识别监听器
    // let extraParam: Record<string, Object> = {
    //   'recognitionMode': 0, // 识别模式。为0表示实时录音识别，为1表示实时音频转文字识别。默认为1
    //   'vadBegin': 2000, // 前端点设置。参数范围是[500,10000]。不传参时默认为10000ms
    //   'vadEnd': 3000, // 后端点设置。参数范围是[500,10000]。不传参时默认为800ms
    //   'maxAudioDuration': 10000 // 最大支持音频时长。短语音模式支持范围[20000-60000]，不传参时默认20000ms
    // }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId, // 会话编号
      audioInfo: this.audioParam, // 音频配置信息
      //   extraParams: extraParam // 额外参数信息
    }
    // 调用开始识别方法
    console.info('startListening start');
    asrEngine.startListening(recognizerParams) // 开始聆听

    // 录音获取音频
    let data: ArrayBuffer;
    this.mFileCapturer = this.mAudioCapturer;
    console.info('create capture success');
    this.mFileCapturer.init((dataBuffer: ArrayBuffer) => {
      console.info('ArrayBuffer ' + JSON.stringify(dataBuffer));
      data = dataBuffer
      let unit8Array: Uint8Array = new Uint8Array(data);
      console.info('ArrayBuffer unit8Array ' + JSON.stringify(unit8Array));
      asrEngine.writeAudio(this.sessionId, unit8Array) // 写入音频流
    });
    this.mFileCapturer.start(() => {
      asrEngine.finish(this.sessionId) // 结束识别
      this.promptAction.showToast({message: '结束语音识别'});
    });
  };

  // 音频转文本
  private writeAudio(fileName: string) {
    this.setListener() // 设置语音识别监听器
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: this.audioParam
    }
    asrEngine.startListening(recognizerParams) // 开始识别

    // 从文件中获取音频
    let data: ArrayBuffer;
    let filePath: string = this.context.cacheDir + '/' + fileName;
    console.info('filePath:'+filePath);
    (this.mFileCapturer as FileCapturer).setFilePath(filePath) // 文件
    this.mFileCapturer.init((dataBuffer: ArrayBuffer) => {
      data = dataBuffer
      let unit8Array: Uint8Array = new Uint8Array(data)
      asrEngine.writeAudio(this.sessionId, unit8Array) // 写入音频流
    });
    this.mFileCapturer.start(() => {
      asrEngine.finish(this.sessionId) // 结束识别
      this.promptAction.showToast({message: '结束语音识别'});
    });
  }

  // 设置语音识别监听器
  private setListener() {
    // 创建语音识别的回调对象
    let listener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart: (sessionId: string, eventMessage: string) => {
        this.generatedText = '';
        console.info('listener onStart sessionId: ' + sessionId + ', eventMessage: ' + eventMessage);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info('listener onEvent sessionId: ' + sessionId + ', eventCode: ' + eventCode + ', eventMessage: ' + eventMessage);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult: (sessionId: string, res: speechRecognizer.SpeechRecognitionResult) => {
        let isFinal: boolean = res.isFinal;
        let isLast: boolean = res.isLast;
        let result: string = res.result;
        this.generatedText = res.result; // 识别的结果文本
        console.info('listener onResult: ' + 'sessionId: ' + sessionId + ' isFinal: ' + isFinal + ' isLast: ' + isLast + ' result: ' + result);
      },
      // 识别完成回调
      onComplete(sessionId: string, eventMessage: string) {
        console.info('listener onComplete sessionId: ' + sessionId + ', eventMessage: ' + eventMessage);
      },
      // 错误回调，错误码通过本方法返回
      // 返回错误码1002200002，开始识别失败，重复启动startListening方法时触发
      // 返回错误码1002200003，输入的音频超过支持的最大音频长度
      // 返回错误码1002200004，结束识别失败，当前没有正在识别的任务时调用finish方法触发
      // 返回错误码1002200005，取消识别失败，当前没有正在识别的任务时调用cancel方法触发
      // 返回错误码1002200006，识别引擎正忙，引擎正在识别中
      // 返回错误码1002200007，引擎未初始化时调用startListening、writeAudio、finish、cancel等方法时触发
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.error('listener onError sessionId: ' + sessionId + ', errorCode: ' + errorCode + ', errorMessage: ' + errorMessage);
      }
    }

    asrEngine.setListener(listener) // 设置语音识别的回调监听器
  }

}