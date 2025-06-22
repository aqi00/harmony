import { hilog } from '@kit.PerformanceAnalysisKit';
import { workScheduler, WorkSchedulerExtensionAbility } from '@kit.BackgroundTasksKit';

export default class WorkSchedulerExtension extends WorkSchedulerExtensionAbility {
  onWorkStart(workInfo: workScheduler.WorkInfo) {
    hilog.info(0x0000, 'testTag', '%{public}s',
      'WorkSchedulerExtensionAbility onWorkStart, workInfo = ' + JSON.stringify(workInfo));
  }

  onWorkStop(workInfo: workScheduler.WorkInfo) {
    hilog.info(0x0000, 'testTag', '%{public}s',
      'WorkSchedulerExtensionAbility onWorkStop, workInfo = ' + JSON.stringify(workInfo));
  }
};