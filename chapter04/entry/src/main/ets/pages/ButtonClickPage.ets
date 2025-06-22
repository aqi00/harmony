import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ButtonClickPage {
  promptAction = this.getUIContext().getPromptAction();

  build() {
      Column() {
        Button('弹出底部提示').fontSize(18).margin(5)
          .onClick(() => {
            this.promptAction.showToast({
              message: '您点击按钮啦',
              duration: 2000
            })
          })
        Button('弹出底部提示（简化写法）').fontSize(18).margin(5)
          .onClick(() => {
            this.promptAction.showToast({ message: '您点击按钮啦' })
          })
        Button('弹出确认窗口').fontSize(18).margin(5)
          .onClick(() => {
            this.promptAction.showDialog({
              title: '请注意',
              message: '您点击按钮啦',
              buttons: [
                { text: '知道了', color: '#000000' }
              ]
            })
          })
        Button('弹出选择窗口').fontSize(18).margin(5)
          .onClick(() => {
            this.promptAction.showDialog({
              title: '请注意',
              message: '您点击按钮啦',
              buttons: [
                { text: '好的', color: '#000000' },
                { text: '取消', color: '#000000' },
              ]
            }, (err, data) => {
              if (err) {
                console.info('showDialog err: ' + err);
                return;
              }
              let index = data.index + 1
              this.promptAction.showToast({ message: '您点击了第' + index + '个按钮' })
            })
          })
        Button('弹出选项菜单').fontSize(18).margin(5)
          .onClick(() => {
            this.promptAction.showActionMenu({
              title: '请选择',
              buttons: [
                { text: '第一项', color: '#000000' },
                { text: '第二项', color: '#000000' },
                { text: '第三项', color: '#000000' },
              ]
            }, (err, data) => {
              if (err) {
                console.info('showActionMenu err: ' + err);
                return;
              }
              let index = data.index + 1
              this.promptAction.showToast({ message: '您点击了第' + index + '个菜单' })
            })
          })
      }
      .width('100%')
  }
}