import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';

let avPlayer: media.AVPlayer; // 声明音视频播放器对象

@Entry
@Component
struct AudioPlayPage {
  context = this.getUIContext().getHostContext() as common.Context;
  @State result: string = ' '; // 播放结果
  @State audioPath: string = ''; // 音频路径
  @State isPlaying: boolean = false; // 是否正在播放
  @State btnText: string = this.isPlaying ? '暂停播放' : '开始播放';
  private file?: fileIo.File; // 待播放的音频文件

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
          this.isPlaying = false
          break;
        case 'playing':
          console.info('state playing called');
          this.isPlaying = true
          break;
        case 'paused':
          console.info('state paused called');
          this.isPlaying = false
          break;
        case 'completed':
          console.info('state completed called');
          this.isPlaying = false
          break;
        case 'stopped':
          console.info('state stopped called');
          this.isPlaying = false
          break;
        case 'released':
          console.info('state released called');
          break;
        case 'error':
          console.info('state error called');
          this.isPlaying = false
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

  aboutToAppear() {
    media.createAVPlayer((error: BusinessError, player: media.AVPlayer) => {
      if (player != null) {
        console.info('Succeeded in creating AVPlayer');
        avPlayer = player // 获得播放器对象
        this.prepare()
      } else {
        console.error(`Failed to create AVPlayer, error message: ${error.message}`);
      }
    });
  }

  aboutToDisappear() {
    avPlayer.off('stateChange')
    avPlayer.off('error')
    if (this.file) {
      fileIo.closeSync(this.file)
    }
  }

  // 选择音频文件
  chooseAudio() {
    let documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let documentPicker = new picker.DocumentViewPicker(this.context);
    documentPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
      console.info('documentPicker.select successfully, documentSelectResult uri: ' + JSON.stringify(documentSelectResult));
      if (documentSelectResult.length == 0) {
        this.result = '请选择文件路径'
        return;
      }
      this.audioPath = documentSelectResult[0]
      this.result = '待播放的文件路径为' + this.audioPath
      this.file = fileIo.openSync(this.audioPath, fileIo.OpenMode.READ_ONLY)
      // url字段要么以fd://打头，要么是有效的网络链接
      avPlayer.url = 'fd://' + this.file.fd
      //avPlayer.url = 'https://ptgl.fujian.gov.cn:8088/masvod/public/2021/03/19/20210319_178498bcae9_r38.mp4'
    }).catch((err: BusinessError) => {
      console.error('documentPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  // 播放音频文件
  playAudio() {
    if (!this.isPlaying) {
      // 开始播放音视频资源，只能在prepared/paused/completed状态调用
      avPlayer.play((err: BusinessError) => {
        if (!err) {
          console.info('Succeeded in playing');
        } else {
          console.error('Failed to play, error message is :' + err.message)
        }
      })
    } else {
      // 暂停播放音视频资源，只能在playing状态调用
      avPlayer.pause((err: BusinessError) => {
        if (err) {
          console.error('Failed to pause, error message is :' + err.message)
        } else {
          console.info('Succeeded in pausing');
        }
      })
    }
  }

  build() {
    Column() {
      Button('选择音频').width('100%').fontSize(18)
        .onClick(() => {
          this.chooseAudio() // 选择音频文件
        })
      Button(this.btnText).width('100%').fontSize(18)
        .onClick(() => {
          this.playAudio() // 播放音频文件
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}