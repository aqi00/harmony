import { textToSpeech } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

let ttsEngine: textToSpeech.TextToSpeechEngine; // TTS引擎实例

@Entry
@Component
struct VoiceTTSPage {
  promptAction = this.getUIContext().getPromptAction();
  @State content: string = '秦时明月汉时关，万里长征人未还。但使龙城飞将在，不教胡马度阴山。';
  @State buttonText: string = '开始朗读'; // 按钮文本
  private isSpeaking = false; // 是否正在朗读

  // 创建TTS引擎。当引擎不存在、引擎资源不存在、初始化超时，返回错误码1002300005，引擎创建失败
  private createTtsEngine() {
    // 设置创建引擎参数
    let initParams: textToSpeech.CreateEngineParams = {
      language: 'zh-CN', // 语种。当前仅支持'zh-CN'表示中文
      person: 0, // 音色。0为聆小珊女声，当前仅支持聆小珊女声。
      online: 1, // 模式。0为在线（暂不支持），1为离线
    };
    // 创建TTS引擎
    textToSpeech.createEngine(initParams).then(textToSpeechEngine => {
      console.info('textToSpeech.createEngine is success');
      ttsEngine = textToSpeechEngine // 返回TTS引擎实例
    }).catch((err: BusinessError) => {
      // 返回错误码1002300005，可能原因：引擎不存在、资源不存在、创建引擎超时
      console.error('textToSpeech.createEngine: err=' + JSON.stringify(err));
    })
  }

  aboutToAppear() {
    this.createTtsEngine() // 创建语音引擎
    this.promptAction.showToast({message: '成功创建语音引擎'});
  }

  aboutToDisappear() {
    ttsEngine.shutdown() // 关闭语音引擎
  }

  build() {
    Column() {
      TextArea({text: $$this.content}).width('100%').height(100)
        .fontSize(18).type(TextAreaType.NORMAL).margin(5)
      Button(this.buttonText).width('100%').fontSize(18)
        .onClick(() => {
          if (this.isSpeaking) {
            ttsEngine.stop() // 停止朗读
          } else {
            // 在播报完成后回调。因为SpeakListener内部不能直接操纵界面控件
            this.speakText(() => {
              this.buttonText = '开始朗读'
              this.isSpeaking = false
            })
          }
          this.buttonText = this.isSpeaking ? '开始朗读' : '停止朗读'
          this.isSpeaking = !this.isSpeaking
        })
    }
    .width('100%').height('100%')
  }

  // 调用speak播报方法。未初始化引擎时调用speak方法，返回错误码1002300007，合成及播报失败
  //speakText(callback: CompleteBack) {
  speakText(callback: () => void) {
    // 设置播报的回调事件
    let speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart(utteranceId: string, response: textToSpeech.StartResponse) {
        console.info('speakListener onStart: ' + ' utteranceId: ' + utteranceId + ' response: ' + JSON.stringify(response));
      },
      // 完成播报回调
      onComplete(utteranceId: string, response: textToSpeech.CompleteResponse) {
        console.info('speakListener onComplete: ' + ' utteranceId: ' + utteranceId + ' response: ' + JSON.stringify(response));
        if (response.type == 1) { // 0为合成结束；1为播报结束
          //callback.onComplete()
          callback() // 播报结束，通知界面刷新播报结果
        }
      },
      // 停止播报完成回调，调用stop方法并完成时会触发此回调
      onStop(utteranceId: string, response: textToSpeech.StopResponse) {
        console.info('speakListener onStop: ' + ' utteranceId: ' + utteranceId + ' response: ' + JSON.stringify(response));
      },
      // 返回音频流
      onData(utteranceId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) {
        console.info('speakListener onData: ' + ' utteranceId: ' + utteranceId + ' sequence: ' + JSON.stringify(response) + ' audio: ' + audio);
      },
      // 错误回调，播报过程发生错误时触发此回调
      // 未创建引擎时调用speak方法时返回错误码1002300007，合成及播报失败
      // 连续调用两次speak，第二次speak会返回错误码1002300006，服务正忙碌
      onError(utteranceId: string, errorCode: number, errorMessage: string) {
        console.error('speakListener onError: ' + ' utteranceId: ' + utteranceId + ' errorCode: ' + errorCode + ' errorMessage: ' + errorMessage);
      }
    };
    ttsEngine.setListener(speakListener) // 设置语音播报的监听器
    // // 设置语音播报参数
    // let extraParam: Record<string, Object> = {
    //   'queueMode': 0, // 排队模式。默认为0表示排队播报。为1表示抢占播报
    //   'speed': 1, // 语速。支持范围[0.5-2]，不传参时默认为1，
    //   'volume': 2, // 音量。支持范围[0-2]，不传参时默认为1
    //   'pitch': 1, // 音调。支持范围[0.5-2]，不传参时默认为1
    //   'languageContext': 'zh-CN', // 播放阿拉伯数字的语境。当前仅支持“zh-CN”中文
    //   'audioType': 'pcm', // 音频类型。当前仅支持“pcm”
    //   'soundChannel': 3, // 声音通道。默认为3表示语音播报
    //   'playType': 1 // 合成类型。0为仅合成不播报，返回音频流。1为合成且播报，不返回音频流。默认为1
    // }
    // let randomId = Math.floor(Math.random() * 10000000000) + ''
    // let speakParams: textToSpeech.SpeakParams = {
    //   requestId: randomId, // 合成播报编号。全局不允许重复
    //   extraParams: extraParam // 额外的播报参数
    // }
    let randomId = Math.floor(Math.random() * 10000000000) + ''
    let speakParams: textToSpeech.SpeakParams = { requestId: randomId }
    ttsEngine.speak(this.content, speakParams) // 开始朗读
  }

}