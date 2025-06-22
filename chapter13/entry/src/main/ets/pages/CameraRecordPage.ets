import { cameraPicker, camera } from '@kit.CameraKit'
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct CameraRecordPage {
  context = this.getUIContext().getHostContext(); // 应用上下文
  @State message: string = ''; // 录像结果
  @State videoPath: string = ''; // 视频路径

  // 唤起相机录像
  startCameraPicker() {
    let pickerProfile: cameraPicker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK, // 后置摄像头
      videoDuration: 15 // 录制的最大时长，单位秒
    };
    // 只处理录像
    cameraPicker.pick(this.context, [cameraPicker.PickerMediaType.VIDEO], pickerProfile)
      .then((pickerResult) => {
        console.info('the pick pickerResult is:' + JSON.stringify(pickerResult));
        this.message = `录像结果代码为${pickerResult.resultCode}，结果路径为${pickerResult.resultUri}`
        this.videoPath = pickerResult.resultUri
      }).catch((err: BusinessError) => {
      console.error('cameraPicker.pick failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('拉起相机录像').width('100%').fontSize(18)
        .onClick(() => {
          this.startCameraPicker() // 唤起相机录像
        })
      Text(this.message).width('100%').padding(5).fontSize(18)
      Video({ src: this.videoPath }).width('100%').layoutWeight(1)
        .objectFit(ImageFit.Contain) // 组件区域包含整个视频画面
        .autoPlay(true) // 是否自动播放
        .controls(true) // 是否显示控制条
    }
    .width('100%').height('100%')
  }
}