import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';
import { Utils } from '../utils/Utils'

let avRecorder: media.AVRecorder; // 声明音视频录制器对象

@Entry
@Component
struct AudioRecordPage {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State result: string = ' '; // 录制结果
  @State isRecording: boolean = false; // 是否正在录制
  @State btnText: string = this.isRecording ? '暂停录制' : '开始录制';
  @State audioPath: string = ''; // 音频路径

  // 创建音频文件
  createAudioFile(): number {
    let update_time = Utils.getNowDatetime()
    this.audioPath = this.context.filesDir + '/' + update_time + '.mp3';
    console.info('audioPath: '+this.audioPath)
    let audioFile = fileIo.openSync(this.audioPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    return audioFile.fd
  }

  // 准备录制
  prepare() {
    avRecorder.on('stateChange', async (state: media.AVRecorderState, reason: media.StateChangeReason) => {
      console.info('case state has changed, new state is :' + state + ',and new reason is : ' + reason);
    });
    avRecorder.on('error', (err: BusinessError) => {
      console.info('case avRecorder.on(error) called, errMessage is ' + err.message);
    });

    // // 配置参数以实际硬件设备支持的范围为准（这里同时录制音频和视频）
    // let avRecorderProfile: media.AVRecorderProfile = {
    //   audioBitrate : 48000,
    //   audioChannels : 2,
    //   audioCodec : media.CodecMimeType.AUDIO_AAC,
    //   audioSampleRate : 48000,
    //   fileFormat : media.ContainerFormatType.CFT_MPEG_4,
    //   videoBitrate : 2000000,
    //   videoCodec : media.CodecMimeType.VIDEO_AVC,
    //   videoFrameWidth : 640,
    //   videoFrameHeight : 480,
    //   videoFrameRate : 30
    // }

    // 配置参数以实际硬件设备支持的范围为准（这里只录制音频）
    let avRecorderProfile: media.AVRecorderProfile = {
      audioBitrate : 48000, // 比特率/码率
      audioChannels : 2, // 声道数
      audioCodec : media.CodecMimeType.AUDIO_MP3, // 音频编码器
      audioSampleRate : 48000, // 采样率
      fileFormat : media.ContainerFormatType.CFT_MP3 // 文件格式
    }

    let fd = this.createAudioFile()
    let avRecorderConfig: media.AVRecorderConfig = {
      audioSourceType : media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      //videoSourceType : media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile : avRecorderProfile,
      url : 'fd://' + fd, // 文件需先由调用者创建，赋予读写权限，将文件fd传给此参数，eg.fd://45
      //rotation : 0, // 合理值0、90、180、270，非合理值prepare接口将报错
      //location : { latitude : 30, longitude : 130 }
    }

    avRecorder.prepare(avRecorderConfig, (err: BusinessError) => {
      if (err) {
        console.error('Failed to prepare and error is ' + err.message);
      } else {
        console.info('Succeeded in preparing');
      }
    })
  }

  aboutToAppear() {
    media.createAVRecorder().then((recorder: media.AVRecorder) => {
      if (recorder != null) {
        console.info('Succeeded in creating AVRecorder');
        avRecorder = recorder;
        this.prepare()
      } else {
        console.error('Failed to create AVRecorder');
      }
    }).catch((err: BusinessError) => {
      console.error(`Failed to create AVRecorder, error message:${err.message}`);
    });
  }

  aboutToDisappear() {
    avRecorder.off('stateChange')
    avRecorder.off('error')
  }

  // 开始录制音频
  recordAudio() {
    if (!this.isRecording) {
      avRecorder.start((err: BusinessError) => {
        if (err) {
          console.error('Failed to start AVRecorder and error is ' + err.message);
          this.result = '录制失败：'+err.message
        } else {
          console.info('Succeeded in starting AVRecorder');
          this.isRecording = true
          this.result = '开始录制'
          this.btnText = '停止录制'
        }
      });
    } else {
      avRecorder.stop((err: BusinessError) => {
        if (err) {
          console.error('Failed to stop AVRecorder and error is ' + err.message);
          this.result = '停止失败：'+err.message
        } else {
          console.info('Succeeded in stopping AVRecorder');
          this.isRecording = false
          this.result = '停止录制'
          this.btnText = '开始录制'
        }
      });
    }
  }

  // 保存音频文件
  saveAudioFile() {
    let fileName = this.audioPath.toString().split('/').pop() as string
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [fileName];
    let documentPicker = new picker.DocumentViewPicker(this.context);
    documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      console.info('DocumentViewPicker.save successfully, documentSaveResult uri: ' + JSON.stringify(documentSaveResult));
      if (documentSaveResult.length == 0) {
        this.result = '请选择文件路径'
        return;
      }
      let dstPath = documentSaveResult[0]
      try {
        let srcFile = fileIo.openSync(this.audioPath.toString());
        let dstFile = fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        fileIo.copyFileSync(srcFile.fd, dstFile.fd);
        fileIo.closeSync(srcFile);
        fileIo.closeSync(dstFile);
      } catch (e) {
        console.info(`copy file failed ${e.message}`);
        return;
      }
      this.result = '文件保存成功'
    }).catch((err: BusinessError) => {
      console.error('DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
      this.result = '文件保存失败：'+JSON.stringify(err)
    });
  }

  build() {
    Column() {
      Button(this.btnText).width('100%').fontSize(18)
        .onClick(() => {
          this.recordAudio() // 开始录制音频
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
      Button('保存录音文件').width('100%').fontSize(18)
        .onClick(() => {
          this.saveAudioFile() // 保存音频文件
        })
    }
    .width('100%').height('100%')
  }
}