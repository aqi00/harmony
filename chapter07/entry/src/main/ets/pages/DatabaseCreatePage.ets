import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct DatabaseCreatePage {
  context = this.getUIContext().getHostContext();
  @State result: string = '';
  private db_store: relationalStore.RdbStore | undefined = undefined; // 数据库实例
  private db_name: string = 'user.db'; // 数据库名称
  private STORE_CONFIG: relationalStore.StoreConfig = {
    name: this.db_name, // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别。安全性从低到高为：S1、S2、S3、S4
    encrypt: false // 是否加密。默认false表示不加密
  };

  build() {
    Column() {
      Row() {
        Button('创建数据库').fontSize(17).layoutWeight(1)
          .onClick(() => {
            relationalStore.getRdbStore(this.context, this.STORE_CONFIG)
              .then((rdbStore: relationalStore.RdbStore) => {
                this.db_store = rdbStore;
                this.result = `数据库${this.db_name}创建成功，版本号为${this.db_store.version}`
                console.info('Get RdbStore successfully.')
              }).catch((err: BusinessError) => {
              this.result = `数据库${this.db_name}创建失败：${err.message}`
              console.error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
            })
          })
        Button('删除数据库').fontSize(17).layoutWeight(1)
          .onClick(() => {
            relationalStore.deleteRdbStore(this.context, this.db_name)
              .then(() => {
                this.db_store = undefined
                this.result = `数据库${this.db_name}删除成功`
              }).catch((err: BusinessError) => {
              this.result = `数据库${this.db_name}删除失败：${err.message}`
              console.error(`Delete RdbStore failed, code is ${err.code},message is ${err.message}`);
            })
          })
      }
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').padding(5)
  }
}