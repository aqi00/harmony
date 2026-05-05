import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import AudioCapturer from '../task/AudioCapturer';
import FileCapturer from '../task/FileCapturer';

let asrEngine: speechRecognizer.SpeechRecognitionEngine; // ASR引擎实例

@Entry
@Component
struct VoiceASRPage {
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext() as common.Context;
  @State sessionId: string = '123456'; // 会话编号
  @State sessionId2: string = '1234567';
  @State generatedText: string = '这里是识别文本';
  private pcmFile1: string = 'night.pcm'; // 夜空日记音频
  private pcmFile2: string = 'spring.pcm'; // 春晓音频
  @State buttonText: string = '开始识别';
  private isRecognizing = false; // 是否正在识别

  private mFileCapturer = new FileCapturer();
  private mAudioCapturer = new AudioCapturer();

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

  private startListeningForRecording() {
    let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 }
    let extraParam: Record<string, Object> = {
      'recognitionMode': 0,
      'vadBegin': 2000,
      'vadEnd': 3000,
      'maxAudioDuration': 20000
    }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: audioParam,
      extraParams: extraParam
    }
    console.info('startListening start');
    asrEngine.startListening(recognizerParams);
  };

  // 麦克风语音转文本
  private async startRecording() {
    this.generatedText = ''
    this.setListener();
    try {
      this.startListeningForRecording();
      // 录音获取音频
      let data: ArrayBuffer;
      console.info('create capture success');
      this.mAudioCapturer.init((dataBuffer: ArrayBuffer) => {
        console.info('start write');
        console.info('ArrayBuffer ' + JSON.stringify(dataBuffer));
        data = dataBuffer
        let uint8Array: Uint8Array = new Uint8Array(data);
        console.info('ArrayBuffer uint8Array ' + JSON.stringify(uint8Array));
        // 写入音频流
        asrEngine.writeAudio(this.sessionId2, uint8Array);
      });
    } catch (err) {
      this.generatedText = `Message: ${err.message}.`;
    }
  };

  // 音频转文本
  private async writeAudio(fileName: string) {
    this.generatedText = ''
    this.setListener() // 设置语音识别监听器
    let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId2,
      audioInfo: audioParam
    }
    asrEngine.startListening(recognizerParams) // 开始识别

    // 从文件中获取音频
    let data: ArrayBuffer;
    let filePath: string = this.context.resourceDir + '/' + fileName;
    console.info('filePath:'+filePath);
    (this.mFileCapturer as FileCapturer).setFilePath(filePath) // 文件
    this.mFileCapturer.init((dataBuffer: ArrayBuffer) => {
      data = dataBuffer
      let uint8Array: Uint8Array = new Uint8Array(data)
      asrEngine.writeAudio(this.sessionId2, uint8Array) // 写入音频流
    });
    await this.mFileCapturer.start();
    this.mFileCapturer.release();
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