import { interactiveLiveness } from '@kit.VisionKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct LivenessDetectPage {
  @State actionsNum: number = 0; // 动作数量
  @State isSilentMode: string = 'INTERACTIVE_MODE'; // 检测模式
  @State routeMode: string = 'replace'; // 跳转模式
  @State resultInfo: interactiveLiveness.InteractiveLivenessResult = {
    livenessType: 0 }; // 检测结果
  @State failResult: Record<string, number | string> = {
    'code': 1008302000,
    'message': ''
  };

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Text('选择模式：').width('25%').fontSize(18)
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Row() {
                Radio({ value: 'INTERACTIVE_MODE', group: 'isSilentMode' }).checked(true)
                  .width(24).height(24)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.isSilentMode = 'INTERACTIVE_MODE'
                    }
                  })
                Text('动作活体检测').fontSize(16)
              }
              .margin({ right: 15 })

              Row() {
                Radio({ value: 'SILENT_MODE', group: 'isSilentMode' }).checked(false)
                  .width(24).height(24)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.isSilentMode = 'SILENT_MODE';
                    }
                  })
                Text('静默活体检测').fontSize(16)
              }
            }
            .width('75%')
          }
        }
        .margin({ bottom: 30 })

        Row() {
          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Text('验证完的跳转模式：').width('25%').fontSize(18)
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Row() {
                Radio({ value: 'replace', group: 'routeMode' }).checked(true)
                  .width(24).height(24)
                  .onChange((isChecked: boolean) => {
                    this.routeMode = 'replace'
                  })
                Text('覆盖').fontSize(16)
              }
              .margin({ right: 15 })

              Row() {
                Radio({ value: 'back', group: 'routeMode' }).checked(false)
                  .width(24).height(24)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.routeMode = 'back';
                    }
                  })
                Text('返回').fontSize(16)
              }
            }
            .width('75%')
          }
        }
        .margin({ bottom: 30 })

        if (this.isSilentMode == 'INTERACTIVE_MODE') {
          Row() {
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Text('动作数量：').width('25%').fontSize(18)
              TextInput({
                placeholder: this.actionsNum != 0 ? this.actionsNum.toString() : '动作数量最多4个'
              })
                .width('65%').type(InputType.Number)
                .fontSize(18).placeholderFont({ size: 18, })
                .onChange((value: string) => {
                  this.actionsNum = Number(value) as interactiveLiveness.ActionsNumber;
                })
            }
          }
        }
      }
      .margin({ left: 24, top: 80 }).zIndex(1)

      Stack({ alignContent: Alignment.Bottom }) {
        if (this.resultInfo?.mPixelMap) {
          Image(this.resultInfo?.mPixelMap)
            .height(260).width(260).margin({ bottom: 260 }).align(Alignment.Center)
          Circle()
            .width(300).height(300).margin({ bottom: 250, left: 0 })
            .strokeWidth(60).stroke(Color.White).fillOpacity(0)
        }

        Text(this.resultInfo.mPixelMap ? '检测成功' :
          this.failResult.code != 1008302000 ? '检测失败' :  '')
          .width('100%').height(26).margin({ top: 50, bottom: 240 })
          .fontSize(20).textAlign(TextAlign.Center)
        if (this.failResult.code != 1008302000) {
          Text(this.failResult.message as string)
            .width('100%').height(26).margin({ bottom: 200 })
            .fontSize(16).fontColor(Color.Gray).textAlign(TextAlign.Center)
        }

        Button('开始检测', { type: ButtonType.Normal, stateEffect: true })
          .width(192).height(40).margin({ bottom: 56 })
          .fontSize(16).backgroundColor(0x317aff).borderRadius(20)
          .onClick(() => {
            this.routerLibrary(); // 跳转到人脸活体验证页面
          })
      }
      .height('100%')
    }
  }

  onPageShow() {
    this.resetResult(); // 重置检测结果
    interactiveLiveness.getInteractiveLivenessResult().then(data => {
      this.resultInfo = data;
    }).catch((err: BusinessError) => {
      this.failResult = {
        'code': err.code,
        'message': err.message
      }
    })
  }

  // 跳转到人脸活体验证页面
  routerLibrary() {
    // let routerOptions: interactiveLiveness.InteractiveLivenessConfig = {
    //   isSilentMode: interactiveLiveness.DetectionMode.INTERACTIVE_MODE }
    let routerOptions: interactiveLiveness.InteractiveLivenessConfig = {
      isSilentMode: this.isSilentMode as interactiveLiveness.DetectionMode,
      routeMode: this.routeMode as interactiveLiveness.RouteRedirectionMode,
      actionsNum: this.actionsNum
    }
    // 开始检测活体
    interactiveLiveness.startLivenessDetection(routerOptions)
      .then((detectState: boolean) => {
        console.info(`Succeeded in jumping. detectState=${detectState}`);
      }).catch((err: BusinessError) => {
      console.error(`Failed to jump. Code：${err.code}，message：${err.message}`);
    })
  }

  // 重置检测结果
  private resetResult() {
    this.resultInfo = { livenessType: 0 }
    this.failResult = {
      'code': 1008302000,
      'message': ''
    }
  }
}