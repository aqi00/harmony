import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { GlobalThis } from '../utils/GlobalThis';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {

  para: Record<string, Object> = { 'name': '' };
  storage_shared: LocalStorage = new LocalStorage(this.para);

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    GlobalThis.getInstance().setContext('context', this.context);
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // loadContent的第二个参数传入页面存储变量，用于页面间共享存储
    windowStage.loadContent('pages/Index', this.storage_shared, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      // 给PersistentStorage绑定待持久化存储的属性
      PersistentStorage.persistProp('name', '');
      PersistentStorage.persistProp('age', 0);
      PersistentStorage.persistProp('stature', 0);
      PersistentStorage.persistProp('weight', 0);
      PersistentStorage.persistProp('ismarried', false);
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}