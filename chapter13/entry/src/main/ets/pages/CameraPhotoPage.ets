import { cameraPicker, camera } from '@kit.CameraKit'
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct CameraPhotoPage {
  context = this.getUIContext().getHostContext(); // 应用上下文
  @State message: string = ''; // 拍照结果
  @State imagePath: string = ''; // 照片路径

  // 唤起相机拍照
  startCameraPicker() {
    let pickerProfile: cameraPicker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK // 后置摄像头
    };
    // 只处理拍照
    cameraPicker.pick(this.context, [cameraPicker.PickerMediaType.PHOTO], pickerProfile)
      .then((pickerResult) => {
        console.info('the pick pickerResult is:' + JSON.stringify(pickerResult));
        this.message = `拍照结果代码为${pickerResult.resultCode}，结果路径为${pickerResult.resultUri}`
        this.imagePath = pickerResult.resultUri
      }).catch((err: BusinessError) => {
      console.error('cameraPicker.pick failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('拉起相机拍照').width('100%').fontSize(18)
        .onClick(() => {
          this.startCameraPicker() // 唤起相机拍照
        })
      Text(this.message).width('100%').fontSize(18).padding(5)
      Image(this.imagePath).width('100%').objectFit(ImageFit.Contain)
    }
    .width('100%').height('100%')
  }
}