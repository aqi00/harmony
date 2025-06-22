import { textRecognition } from '@kit.CoreVisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';

import { textToSpeech } from '@kit.CoreSpeechKit';
let ttsEngine: textToSpeech.TextToSpeechEngine; // TTS引擎实例

@Entry
@Component
struct TextRecognizePage {
  @State result: string = '识别结果在这里'; // 识别结果
  @State imagePath: string = ''; // 待识别的图片路径
  @State pixelMap: PixelMap | undefined = undefined; // 待识别像素图

  @State buttonText: string = '开始朗读';
  private isSpeaking = false; // 是否正在朗读

  // 创建TTS引擎。当引擎不存在、引擎资源不存在、初始化超时，返回错误码1002300005，引擎创建失败
  createTtsEngine() {
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
  }

  aboutToDisappear() {
    ttsEngine.shutdown() // 关闭语音引擎
  }

  // 调用speak播报方法。未初始化引擎时调用speak方法，返回错误码1002300007，合成及播报失败
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
    let randomId = Math.floor(Math.random() * 10000000000) + ''
    let speakParams: textToSpeech.SpeakParams = { requestId: randomId }
    ttsEngine.speak(this.result, speakParams) // 开始朗读
  }

  // 选择相册图片
  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      this.imagePath = photoSelectResult.photoUris[0]
      let file = fileIo.openSync(this.imagePath, fileIo.OpenMode.READ_ONLY);
      let imageSource = image.createImageSource(file.fd);
      this.pixelMap = imageSource.createPixelMapSync() // 把图片文件转换为像素图
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  // 识别图片中的文字
  recognizeText() {
    if (!this.pixelMap) {
      return;
    }
    let visionInfo: textRecognition.VisionInfo = { pixelMap: this.pixelMap };
    let textConfiguration: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false };
    // 调用文本识别接口
    textRecognition.recognizeText(visionInfo, textConfiguration)
      .then((data: textRecognition.TextRecognitionResult) => {
        let recognitionString = data.toString();
        console.info(`Succeeded in recognizing text：${recognitionString}`);
        this.result = data.value; // 将结果更新到Text组件中显示
        if (this.pixelMap) {
          this.pixelMap.release();
        }
      }).catch((err: BusinessError) => {
      console.error('textRecognition.recognizeText: err=' + JSON.stringify(err));
    })
  }

  build() {
    Column() {
      Button('到相册选择图片').width('100%').fontSize(18)
        .onClick(() => {
          this.choosePhoto() // 选择相册图片
        })
      Image(this.imagePath).width('100%').height('40%').objectFit(ImageFit.Contain)
      // Button('开始识别文字').width('100%').fontSize(18)
      //   .onClick(() => {
      //     this.recognizeText() // 识别图片中的文字
      //   })
      // Text(this.result).width('100%').fontSize(18).padding(5)
      Row() {
        Button('开始识别文字').layoutWeight(1).fontSize(18)
          .onClick(() => {
            this.recognizeText() // 识别图片中的文字
          })
        Button(this.buttonText).layoutWeight(1).fontSize(18)
          .onClick(() => {
            if (this.isSpeaking) {
              ttsEngine.stop() // 停止朗读
            } else {
              this.speakText(() => {
                this.buttonText = '开始朗读'
                this.isSpeaking = false
              })
            }
            this.buttonText = this.isSpeaking ? '开始朗读' : '停止朗读'
            this.isSpeaking = !this.isSpeaking
          })
      }.width('100%')
      TextArea({text: $$this.result }).width('100%').fontSize(18).padding(5)
        .copyOption(CopyOptions.LocalDevice)
    }
    .width('100%').height('100%')
  }

}