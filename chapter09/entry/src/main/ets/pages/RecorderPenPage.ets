import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';

import { media } from '@kit.MediaKit';
import { fileIo } from '@kit.CoreFileKit';
import { Utils } from '../utils/Utils'
let avRecorder: media.AVRecorder; // 声明音视频录制器对象

@Entry
@Component
struct RecorderPenPage {
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State title: string = '录音笔';
  @State content: string = '正在录音……';
  private count: number = 0; // 计数值
  private tid: number = -1; // 定时器编号

  private filePath: string = ''; // 录音文件路径
  // 创建音频文件
  createAudioFile(): number {
    let update_time = Utils.getNowDatetime()
    this.filePath = this.context.filesDir + '/' + update_time + '.mp3';
    console.info('filePath: '+this.filePath)
    let audioFile = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    return audioFile.fd
  }

  // 准备录音
  prepare() {
    avRecorder.on('stateChange', async (state: media.AVRecorderState, reason: media.StateChangeReason) => {
      console.info('case state has changed, new state is :' + state + ',and new reason is : ' + reason);
    });
    avRecorder.on('error', (err: BusinessError) => {
      console.info('case avRecorder.on(error) called, errMessage is ' + err.message);
    });
    // 配置参数以实际硬件设备支持的范围为准
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
      profile : avRecorderProfile,
      url : 'fd://' + fd, // 文件需先由调用者创建，赋予读写权限，将文件fd传给此参数，eg.fd://45
    }
    avRecorder.prepare(avRecorderConfig, (err: BusinessError) => {
      if (err) {
        console.error('Failed to prepare and error is ' + err.message);
      } else {
        console.info('Succeeded in preparing');
      }
    })
  }

  onPageShow() {
    media.createAVRecorder().then((recorder: media.AVRecorder) => {
      if (recorder != null) {
        console.info('Succeeded in creating AVRecorder');
        avRecorder = recorder;
        this.prepare() // 准备录音
      } else {
        console.error('Failed to create AVRecorder');
      }
    }).catch((err: BusinessError) => {
      console.error(`Failed to create AVRecorder, error message:${err.message}`);
    });
  }

  onPageHide() {
    avRecorder.off('stateChange')
    avRecorder.off('error')
  }

  // 开始录音
  record() {
    avRecorder.start((err: BusinessError) => {
      if (err) {
        console.error('Failed to start AVRecorder and error is ' + err.message);
      } else {
        console.info('Succeeded in starting AVRecorder');
      }
    });
  }

  private wantAgentObj?: WantAgent; // 应用的行为意图

  aboutToAppear() {
    let notifyEnable = notificationManager.isNotificationEnabledSync()
    if (!notifyEnable) {
      notificationManager.requestEnableNotification(this.context, (err: BusinessError): void => {
        if (err) {
          console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
        } else {
          console.info("requestEnableNotification success");
          notificationManager.isSupportTemplate('downloadTemplate').then(isSupport => {
            if (!isSupport) {
              this.promptAction.showToast({message: '系统不支持进度条模板'})
            }
          });
        }
      })
    }
  }

  // 申请长时任务
  startLongTask() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表。添加需要被拉起应用的bundleName和abilityName
      wants: [{
          bundleName: context.abilityInfo.bundleName, // 包名
          abilityName: 'Chapter08Ability', // Ability名称
        }],
      // 点击通知后的动作类型
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0, // 请求代码
      // 点击通知后的动作执行属性
      // actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo) // 获取应用的行为意图
      .then((wantAgentObj: WantAgent) => {
        this.wantAgentObj = wantAgentObj // 保存应用的行为意图
        // 这里startBackgroundRunning传了wantAgentObj，还要另外推送通知栏吗？
        // 长时任务选择AUDIO_RECORDING表示录音，那么系统会监控App是否有录音操作。
        // 如果没有录音动作，则App仍然会被挂起；只有正在录音时，才允许App继续运行
        backgroundTaskManager.startBackgroundRunning(this.context,
          backgroundTaskManager.BackgroundMode.AUDIO_RECORDING, wantAgentObj).then(() => {
          console.info(`Succeeded in operationing startBackgroundRunning.`);
        }).catch((err: BusinessError) => {
          console.error(`Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
        });
      });
  }

  // 取消长时任务
  stopLongTask() {
    // 停止长时任务
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
      console.info(`Succeeded in operationing stopBackgroundRunning.`);
    }).catch((err: BusinessError) => {
      console.error(`Failed to operation stopBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
    });
  }

  // 发送消息通知
  sendNotification() {
    let template: notificationManager.NotificationTemplate = {
      name: 'downloadTemplate', // 进度条模板的名称固定填downloadTemplate
      data: {
        title: this.title, // 下载标题。必填
        fileName: this.content, // 文件名称。必填
        progressValue: this.count++, // 当前进度值
        progressMaxValue: 100 // 最大进度值
      }
    }
    // 通知Request对象
    let notificationRequest: notificationManager.NotificationRequest = {
      id: 1, // 通知编号
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: this.title, // 通知标题
          text: this.content // 通知内容
        }
      },
      template: template // 通知模板
    };
    // 发布消息通知
    notificationManager.publish(notificationRequest, (err: BusinessError): void => {
      if (err) {
        console.error(`publish failed, code is ${err.code}, message is ${err.message}`);
      } else {
        console.info('publish success, count='+this.count);
      }
    });
    if (this.count >= 100) {
      clearInterval(this.tid) // 计数值达到100时，清除定时器
    }
  }

  build() {
    Column() {
      Row() {
        Text('消息标题：').fontSize(18)
        TextInput({ text: $$this.title, placeholder: '请输入消息标题' })
          .type(InputType.Normal).fontSize(18).layoutWeight(3)
      }.padding(5).visibility(Visibility.Hidden)
      Row() {
        Text('消息内容：').fontSize(18)
        TextInput({ text: $$this.content, placeholder: '请输入消息内容' })
          .type(InputType.Normal).fontSize(18).layoutWeight(3)
      }.padding(5).visibility(Visibility.Hidden)
      Button('开始录音（未申请长时任务）')
        .fontSize(18).width('100%').margin({ top: 5 })
        .onClick(() => {
          this.record() // 开始录音
          clearInterval(this.tid) // 清除定时任务
          this.count = 0
          this.tid = setInterval((): void => this.sendNotification(), 200)
          this.promptAction.showToast({message: '已发送录音消息，请前往通知栏查看'})
        })
      Button('开始录音（已申请长时任务）')
        .fontSize(18).width('100%').margin({ top: 5 })
        .onClick(() => {
          this.startLongTask(); // 申请长时任务
          // 此处执行具体的长时任务逻辑，如播音、录音、下载大文件等。如果没有录音，则App仍然会被系统挂起
          this.record() // 开始录音
          clearInterval(this.tid) // 清除定时任务
          this.count = 0
          this.tid = setInterval((): void => this.sendNotification(), 200)
          this.promptAction.showToast({message: '已发送录音消息，请前往通知栏查看'})
        })
      Button('取消录音')
        .fontSize(18).width('100%').margin({ top: 5 })
        .onClick(() => {
          // 此处结束具体的长时任务的执行，比如停止播音、结束录音、中断下载等等
          clearInterval(this.tid) // 清除定时任务
          this.stopLongTask(); // 取消长时任务
        })
    }
    .width('100%').height('100%')
  }
}