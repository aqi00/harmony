import { common } from '@kit.AbilityKit';

@Entry
@Component
struct FilePathPage {
  @State result: string = ''; // 读取结果
  // 应用级别的上下文对象
  appContext = this.getUIContext().getHostContext()?.getApplicationContext();
  // HAP级别的上下文对象
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Column() {
      Button('获取文件路径').fontSize(18).width('100%')
        .onClick(() => {
          let appCacheDir = this.appContext?.cacheDir;
          let appTempDir = this.appContext?.tempDir;
          let appFilesDir = this.appContext?.filesDir;
          let appPreferencesDir = this.appContext?.preferencesDir;
          let appDatabaseDir = this.appContext?.databaseDir;
          let appBundleCodeDir = this.appContext?.bundleCodeDir;
          let appDistributedFilesDir = this.appContext?.distributedFilesDir;
          let uiCacheDir = this.context.cacheDir;
          let uiTempDir = this.context.tempDir;
          let uiFilesDir = this.context.filesDir;
          let uiPreferencesDir = this.context.preferencesDir;
          let uiDatabaseDir = this.context.databaseDir;
          let uiBundleCodeDir = this.context.bundleCodeDir;
          let uiDistributedFilesDir = this.context.distributedFilesDir;
          this.result = `应用级别目录路径如下：\n　缓存目录路径为${appCacheDir}` +
            `\n　临时目录路径为${appTempDir}` +
            `\n　文件目录路径为${appFilesDir}` +
            `\n　首选项目录路径为${appPreferencesDir}` +
            `\n　数据库目录路径为${appDatabaseDir}` +
            `\n　安装文件目录路径为${appBundleCodeDir}` +
            `\n　分布式文件目录路径为${appDistributedFilesDir}` +
            `\nHAP级别目录路径如下：\n　缓存目录路径为${uiCacheDir}` +
            `\n　临时目录路径为${uiTempDir}` +
            `\n　文件目录路径为${uiFilesDir}` +
            `\n　首选项目录路径为${uiPreferencesDir}` +
            `\n　数据库目录路径为${uiDatabaseDir}` +
            `\n　安装文件目录路径为${uiBundleCodeDir}` +
            `\n　分布式文件目录路径为${uiDistributedFilesDir}`
          console.info(this.result)
        })
      Text(this.result).fontSize(17).padding(2).width('100%')
    }
    .width('100%').padding(5)
  }
}