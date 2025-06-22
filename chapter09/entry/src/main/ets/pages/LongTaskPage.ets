import { common } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';

@Entry
@Component
struct LongTaskPage {
  context = this.getUIContext().getHostContext();
  private wantAgentObj?: WantAgent; // 应用的行为意图

  // 申请长时任务
  startLongTask() {
    let bundleName = (this.context as common.UIAbilityContext).abilityInfo.bundleName
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表。添加需要被拉起应用的bundleName和abilityName
      wants: [{
          bundleName: bundleName, // 包名
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

  build() {
    Column() {
      Button('申请长时任务').fontSize(18).width('100%').margin({ top: 5 })
        .onClick(() => {
          this.startLongTask() // 申请长时任务
          // 下面执行具体的长时任务逻辑，如开始录音
        })
      Button('取消长时任务').fontSize(18).width('100%').margin({ top: 5 })
        .onClick(() => {
          // 此处结束长时任务，如结束录音
          this.stopLongTask() // 取消长时任务
        })
    }
    .width('100%').height('100%')
  }
}