import { common } from '@kit.AbilityKit';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { geoLocationManager } from '@kit.LocationKit';
import { window } from '@kit.ArkUI';

import { Utils } from '../utils/Utils';
import { PoemInfo } from '../entity/PoemInfo';
import { PoemDB } from '../entity/PoemDB';
import { QuestionInfo } from '../entity/QuestionInfo';
import { QuestionDB } from '../entity/QuestionDB';
import { CityInfo } from '../entity/CityInfo';
import { WeatherResp } from '../entity/WeatherResp';
import { CityResp } from '../entity/CityResp';
import { UrlConstant } from '../constant/UrlConstant';
import { RobotConstant } from '../constant/RobotConstant';

import { fileIo } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { textToSpeech } from '@kit.CoreSpeechKit';
import AudioCapturer from '../task/AudioCapturer';
import { preferences } from '@kit.ArkData';

let avPlayer: media.AVPlayer; // 声明音视频播放器对象
let asrEngine: speechRecognizer.SpeechRecognitionEngine; // ASR引擎实例
let ttsEngine: textToSpeech.TextToSpeechEngine; // TTS引擎实例

@Entry
@Component
struct RobotPage {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  router = this.getUIContext().getRouter();
  private cityInfo: CityInfo | undefined // 城市信息
  private questionSystemMap: Map<string, QuestionInfo> = new Map<string, QuestionInfo>() // 系统自带的问答映射
  private questionCustomMap: Map<string, QuestionInfo> = new Map<string, QuestionInfo>() // 用户添加的问答映射
  private poemList: PoemInfo[] = []
  private poemDao: PoemDB = new PoemDB()
  private questionDao: QuestionDB = new QuestionDB()
  private dataPref?: preferences.Preferences; // 首选项实例

  @State sessionId: string = '123456'; // 会话编号
  @State sessionId2: string = '1234567';
  private mAudioCapturer = new AudioCapturer();
  @State question: string = '您好，很高兴为您服务。\n有什么可以帮您的呢O(∩_∩)O';
  @State answer: string = '我的回答在这里哦~\\(^o^)/~';

  // 准备播放
  prepare() {
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          console.info('state idle called');
          break;
        case 'initialized':
          console.info('initialized prepared called');
          // 准备播放音频/视频，需在stateChange事件成功触发至initialized状态后，才能调用
          avPlayer.prepare().then(() => {
            console.info('Succeeded in preparing');
          }, (err: BusinessError) => {
            console.error('Failed to prepare,error message is :' + err.message)
          })
          break;
        case 'prepared':
          console.info('state prepared called');
          break;
        case 'playing':
          console.info('state playing called');
          break;
        case 'paused':
          console.info('state paused called');
          break;
        case 'completed':
          console.info('state completed called');
          setTimeout(() => {
            this.startRecording() // 开始录音
          }, 300)
          avPlayer.reset((err: BusinessError) => {
            if (err) {
              console.error('Failed to reset,error message is :' + err.message)
            } else {
              console.info('Succeeded in resetting');
            }
          })
          break;
        case 'stopped':
          console.info('state stopped called');
          break;
        case 'released':
          console.info('state released called');
          break;
        case 'error':
          console.info('state error called');
          break;
        default:
          console.info('unknown state :' + state);
          break;
      }
    })
    avPlayer.on('error', (err: BusinessError) => {
      console.info('error happened,and error message is :' + err.message)
      console.info('error happened,and error code is :' + err.code)
    })
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

  // 设置常亮状态
  setKeepScreenOn(isKeepScreenOn: boolean) {
    window.getLastWindow(this.getUIContext().getHostContext()).then((curWindow) => {
      curWindow.setWindowKeepScreenOn(isKeepScreenOn, (err: BusinessError) => {
        if (err.code) {
          console.error(`操作失败，错误码: ${err.code}`);
          return;
        }
        console.info(`屏幕常亮状态: ${isKeepScreenOn}`);
      });
    }).catch((err: Error) => {
      console.error(`获取窗口失败: ${err}`);
    });
  }

  aboutToAppear(): void {
    let options: preferences.Options = { name: 'robot_store' };
    this.dataPref = preferences.getPreferencesSync(this.context, options);
    let haveInit = this.dataPref?.getSync('have_init', false)
    console.info('haveInit='+haveInit)
    if (!haveInit) {
      setTimeout(() => {
        this.initQuestionAndPoem() // 初始化所有问答和诗歌
        this.dataPref?.putSync('have_init', true)
      }, 20)
    }
    setTimeout(() => {
      this.loadQuestionAndPoem() // 加载所有问答和诗歌
    }, 500)
    media.createAVPlayer((error: BusinessError, player: media.AVPlayer) => {
      if (player != null) {
        console.info('Succeeded in creating AVPlayer');
        avPlayer = player // 获得播放器对象
        this.prepare()
      } else {
        console.error(`Failed to create AVPlayer, error message: ${error.message}`);
      }
    });
    this.createAsrEngine() // 创建ASR引擎
    this.createTtsEngine() // 创建语音引擎
    this.setKeepScreenOn(true); // 页面显示时开启常亮
  }

  aboutToDisappear(): void {
    avPlayer.off('stateChange')
    avPlayer.off('error')
    asrEngine.shutdown() // 关闭ASR引擎
    ttsEngine.shutdown() // 关闭语音引擎
    this.setKeepScreenOn(false); // 页面消失时关闭常亮
  }

  onPageShow(): void {
    this.startLocate()
    setTimeout(() => {
      let voicePath = RobotConstant.SAMPLE_PATHS[0]
      this.playVoice(voicePath) // 播放预设的音频文件
    }, 300)
  }

  onPageHide(): void {
    asrEngine.finish(this.sessionId) // 结束识别
    avPlayer.stop()
  }

  // 初始化所有问答和诗歌
  initQuestionAndPoem() {
    // 初始化系统设定的问题
    RobotConstant.initSystemQuestion(this.context, this.questionDao)
    // 初始化古诗数据
    RobotConstant.initPoetryData(this.context, this.poemDao)
    RobotConstant.copySampleFiles(this.context)
  }

  // 加载所有问答和诗歌
  loadQuestionAndPoem() {
    let questionList = this.questionDao.queryAll(); // 加载所有问答信息
    for (let item of questionList) {
      if (item.type == 0) { // 系统问答
        this.questionSystemMap.set(item.question, item);
      } else { // 用户问答
        this.questionCustomMap.set(item.question, item);
      }
    }
    console.info('SystemMap.length=' + this.questionSystemMap.size + ',CustomMap.length=' + this.questionCustomMap.size);
    this.poemList = this.poemDao.queryAll(); // 加载所有诗歌信息
    console.info('poemList.length=' + this.poemList.length);
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_back')).width('35').height('35')
          .onClick(() => {
            this.router.back() // 关闭当前页面
          })
        Text('小小机器人').layoutWeight(1).fontSize(20).textAlign(TextAlign.Start).padding({left:10})
      }
      .width('100%').height(60).padding(10)
      Divider().width('100%').color(Color.Gray).padding({left:10, right:10})

      Text(this.question).width('100%').fontSize(17).textAlign(TextAlign.Center)
        .constraintSize({minHeight: 80})
      Image($r('app.media.robot')).width('100%').height('400').objectFit(ImageFit.Contain)
      Text(this.answer).width('100%').fontSize(17).textAlign(TextAlign.Center)
        .layoutWeight(1)

      Row() {
        Button('查看问答列表').layoutWeight(1).fontSize(17)
          .onClick(() => {
            this.router.pushUrl({ url: 'robot/QuestionListPage' })
          })
        Button('添加新的问答').layoutWeight(1).fontSize(17)
          .onClick(() => {
            this.router.pushUrl({
              url: 'robot/QuestionEditPage',
              params: { id: -1 }
            })
          })
      }.width('100%').padding(5)
    }
    .width('100%').height('100%')
  }

  private sourceArray: string[] = ['未知', '卫星定位',
    '网络定位', '室内高精度定位', '室外高精度定位'];

  // 获取详细地址
  getAddress(location: geoLocationManager.Location) {
    let geocoderAvailable = geoLocationManager.isGeocoderAvailable();
    console.info('geocoderAvailable='+geocoderAvailable)
    if (!geocoderAvailable) {
      console.error('逆地理编码服务不可用');
      return
    }
    let reverseGeocodeRequest:geoLocationManager.ReverseGeoCodeRequest =
      {'latitude': location.latitude, 'longitude': location.longitude, 'maxItems': 1};
    geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest)
      .then((data: Array<geoLocationManager.GeoAddress>) => {
        if (data) {
          console.info('getAddressesFromLocation: data=' + JSON.stringify(data));
          let descriptions = data[0].descriptions
          let cityCode = descriptions==undefined ? '' : descriptions[0]
          let adminCode = descriptions==undefined ? '' : descriptions[1]
          let message = `详细地址为${data[0].placeName}\n` +
            `二级政区为${data[0].subAdministrativeArea}，城市为${data[0].locality}\n` +
            `城市代码为${cityCode}，区域代码为${adminCode}`
          console.info(message)
          this.cityInfo = new CityInfo(data[0].administrativeArea!, data[0].subAdministrativeArea!, data[0].subLocality!, data[0].placeName!)
          this.queryCity(data[0].locality!)
        }
      }).catch((err: BusinessError) => {
      console.error('getAddressesFromLocation: err=' + JSON.stringify(err));
    })
  }

  // 开始定位
  startLocate() {
    console.info('正在定位，请等待……');
    let locationEnabled = geoLocationManager.isLocationEnabled();
    console.info('locationEnabled='+locationEnabled)
    if (!locationEnabled) {
      console.error('定位服务不可用');
      return
    }
    try {
      let location = geoLocationManager.getLastLocation()
      console.info('last location: ' + JSON.stringify(location));
      geoLocationManager.getCurrentLocation().then((location) => {
        console.info('current location: ' + JSON.stringify(location));
        let locationTime = Utils.getFormatDatetime(location.timeStamp)
        let message = `定位信息如下：\n` +
          `定位来源为${this.sourceArray[location.sourceType?location.sourceType:0]}\n` +
          `定位时间为${locationTime}\n经度为${location.longitude}\n纬度为${location.latitude}\n` +
          `高度为${Math.round(location.altitude)}米，精度为${Math.round(location.accuracy)}米\n`
        console.info(message)
        this.getAddress(location) // 获取详细地址
      }).catch((error: BusinessError) => {
        console.error('promise, getCurrentLocation: error=' + JSON.stringify(error));
      });
    } catch (err) {
      console.error('getLastLocation: error=' + JSON.stringify(err));
    }
  }

  // 请求城市接口
  queryCity(city: string) {
    // 每个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 订阅HTTP响应头事件
    httpRequest.on('headersReceive', (header: Object) => {
      console.info('header: ' + JSON.stringify(header));
    });
    let options: http.HttpRequestOptions ={
      method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
      header: { // 请求包头
        'Accept-Language': 'zh-CN',
      },
    }
    let url = util.format(UrlConstant.url_city, city)
    // 根据URL地址，发起HTTP网络请求，使用callback方式作为异步回调
    httpRequest.request(url, options,
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          let resp = data.result.toString()
          let cityResp = JSON.parse(resp) as CityResp // 把JSON字符串解析为对象实例
          if (cityResp.status==='1' && cityResp.districts!=null && cityResp.districts.length>0) {
            let cityInfo = cityResp.districts[0]
            this.queryWeather(cityInfo.adcode)
          }
          console.info('Result:' + JSON.stringify(data.result));
        } else {
          console.error('error:' + JSON.stringify(err));
        }
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript对象
        httpRequest.destroy();
      })
  }

  // 请求天气接口
  queryWeather(city: string) {
    this.cityInfo!.city_code = city
    // 每个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 订阅HTTP响应头事件
    httpRequest.on('headersReceive', (header: Object) => {
      console.info('header: ' + JSON.stringify(header));
    });
    let options: http.HttpRequestOptions ={
      method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
      header: { // 请求包头
        'Accept-Language': 'zh-CN',
      },
    }
    let url = util.format(UrlConstant.url_weather, city)
    // 根据URL地址，发起HTTP网络请求，使用callback方式作为异步回调
    httpRequest.request(url, options,
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          let resp = data.result.toString()
          let weatherResp = JSON.parse(resp) as WeatherResp // 把JSON字符串解析为对象实例
          if (weatherResp.status==='1' && weatherResp.lives!=null && weatherResp.lives.length>0) {
            this.cityInfo!.weather_info = weatherResp.lives[0]
          }
          console.info('Result:' + JSON.stringify(data.result));
        } else {
          console.error('error:' + JSON.stringify(err));
        }
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript对象
        httpRequest.destroy();
      })
  }

  // 开始聆听用户说话
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
    this.setListener(() => {
      setTimeout(() => {
        this.startRecording() // 开始录音
      }, 300)
    });
    try {
      this.startListeningForRecording(); // 开始聆听用户说话
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
      console.error('startRecording: error=' + JSON.stringify(err));
    }
  }

  // 设置语音识别监听器
  private setListener(callback: () => void) {
    // 创建语音识别的回调对象
    let listener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart: (sessionId: string, eventMessage: string) => {
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
        console.info('listener onResult: ' + 'sessionId: ' + sessionId + ' isFinal: ' + isFinal + ' isLast: ' + isLast + ' result: ' + result);
        this.question = '您的问题是：' + res.result; // 识别的结果文本
        if (res.result!=undefined && res.result!='') {
          this.checkRecognize(res.isFinal, res.result)
        } else {
          callback() // 未识别到文本，继续监听
        }
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

  private poemPos: number = -1; // 诗歌在列表中的位置
  // 检查已识别的文本是否为已设定的问题
  checkRecognize(isEnd: boolean, result: string) {
    if (!isEnd) {
      return
    }
    let text = result.replaceAll('，', '').replaceAll('。', '')
    for (let item of this.questionCustomMap) {
      console.info(`Custom question key=${item[0]}, value=${item[1].question}`)
      if (text.includes(item[0])) { // 匹配用户添加的问题
        if (isEnd) { // 已经结束识别
          this.answerCustomQuestion(item[1]); // 回答用户问题
        }
        return;
      }
    }
    for (let item of this.questionSystemMap) {
      console.info(`System question key=${item[0]}, value=${item[1].question}`)
      const reg_system = new RegExp(item[0]);
      if (reg_system.test(text)) { // 匹配系统自带的问题
        if (isEnd) { // 已经结束识别
          this.answerSystemQuestion(text, item[1]); // 回答系统问题
        }
        return;
      }
    }
    console.info('RECITE_PATTERN='+RobotConstant.RECITE_PATTERN)
    const reg_recite = new RegExp(RobotConstant.RECITE_PATTERN);
    if (reg_recite.test(text)) { // 匹配诗歌背诵
      const reg = new RegExp(RobotConstant.RECITE_PART);
      let recites = text.split(reg);
      console.info('recites.length='+recites.length)
      if (recites.length < 2) {
        return;
      }
      console.info('content='+recites[1])
      if (isEnd) { // 已经结束识别
        if (this.poemPos == -1) {
          this.poemPos = RobotConstant.searchPoemPos(recites[1], this.poemPos, this.poemList);
        }
        console.info('this.poemPos='+this.poemPos)
        if (this.poemPos != -1) {
          this.readPoem(this.poemList[this.poemPos]); // // 朗读诗歌
          return;
        }
      }
    }
    this.answer = '我的回答是：'+RobotConstant.SYSTEM_ANSWERS[6]
    let voicePath = RobotConstant.SAMPLE_PATHS[6]
    this.playVoice(voicePath) // 播放预设的音频文件
  }

  // 朗读诗歌
  readPoem(poem: PoemInfo) {
    this.poemPos = -1;
    console.info('readPoem poem.content=' + poem.content);
    let poemContent = poem.content.replaceAll('\\n', '\n');
    if (poemContent.slice(-1) != '。') {
      poemContent = poemContent.slice(0, -1)
    }
    let showText = util.format('%s\n%s\n%s', poem.title, poem.author, poemContent);
    console.info('readPoem answer=' + showText);
    this.answer = showText
    this.speakText(this.answer) // 朗读答案
  }

  // 回答系统问题
  answerSystemQuestion(question: string, questionInfo: QuestionInfo) {
    let answer = questionInfo.answer;
    console.info('answerSystemQuestion answer='+answer);
    let judgeResult = RobotConstant.judgeAnswerResult(question, answer, this.cityInfo!);
    let voiceSeq = judgeResult.seq;
    let tempText = judgeResult.answer;
    console.info(`answerSystemQuestion voiceSeq=${voiceSeq}, answer=${tempText}`);
    let answerText = tempText==='' ? RobotConstant.SYSTEM_ANSWERS[voiceSeq] : tempText;
    this.answer = '我的回答是：'+answerText
    let voicePath = voiceSeq==-1 ? '' : RobotConstant.SAMPLE_PATHS[voiceSeq];
    // console.info('voiceSeq='+voiceSeq+',answerText='+answerText+',voicePath='+voicePath);
    if (voiceSeq >= 0) {
      this.playVoice(voicePath) // 播放预设的音频文件
    } else {
      this.speakText(answerText)
    }
  }

  // 回答用户问题
  answerCustomQuestion(questionInfo: QuestionInfo) {
    let answerText = questionInfo.answer;
    console.info('answerCustomQuestion answer=' + answerText);
    this.answer = '我的回答是：'+answerText
    this.speakText(answerText) // 朗读答案
  }


  speakText(content: string) {
    this.speakTextReal(content, () => {
      setTimeout(() => {
        this.startRecording() // 开始录音
      }, 300)
    })
  }

  // 调用speak播报方法。未初始化引擎时调用speak方法，返回错误码1002300007，合成及播报失败
  speakTextReal(content: string, callback: () => void) {
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
    ttsEngine.speak(content, speakParams) // 开始朗读
  }

  playVoice(voicePath: string) {
    console.info('voicePath:'+voicePath)
    console.info('111 avPlayer.state:'+avPlayer.state)
    let file = fileIo.openSync(voicePath, fileIo.OpenMode.READ_ONLY)
    // url字段要么以fd://打头，要么是有效的网络链接
    avPlayer.url = 'fd://' + file.fd
    setTimeout(() => {
      console.info('222 avPlayer.state:'+avPlayer.state)
      // 开始播放音视频资源，只能在prepared/paused/completed状态调用
      avPlayer.play((err: BusinessError) => {
        if (!err) {
          console.info('Succeeded in playing');
        } else {
          console.error('Failed to play, error message is :' + err.message)
        }
      })
    }, 200)
  }

}