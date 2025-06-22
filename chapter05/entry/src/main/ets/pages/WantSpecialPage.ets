import { call } from '@kit.TelephonyKit';
import { contact } from '@kit.ContactsKit';

@Entry
@Component
struct WantSpecialPage {
  @State message: string = '请打开通讯录选择联系人';

  build() {
    Column() {
      Row() {
        Button('打开拨号页').fontSize(17).layoutWeight(1)
          .onClick(() => {
            // call.hasCallSync() // 判断是否正在通话
            // 是否支持语音通话功能
            let isSupport = call.hasVoiceCapability();
            if (!isSupport) {
              console.error('Not support voice capability.');
              return;
            }
            call.makeCall('16888888888') // 跳到待拨打号码的拨号页面
          })
        Button('打开通讯录').fontSize(17).layoutWeight(1)
          .onClick(() => {
            // 打开通讯录选择联系人
            contact.selectContacts((err, data) => {
              if (err) {
                console.error(`selectContacts callback: err->${JSON.stringify(err)}`);
                return;
              }
              console.info(`selectContacts callback: success data->${JSON.stringify(data)}`);
              this.message = '您选择的联系人如下：'
              for (let item of data) {
                let phoneArray = item.phoneNumbers as contact.PhoneNumber[]
                this.message = `${this.message}\n\t姓名是${item.name?.fullName}，手机号是${phoneArray[0].phoneNumber}`
              }
            });
          })
      }.padding({top: 6, bottom: 6})
      Text(this.message).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}