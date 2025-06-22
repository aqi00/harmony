import { router } from '@kit.ArkUI';
import { cameraPicker, camera } from '@kit.CameraKit'
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Entry
@Component
struct ShortTakePage {
  router = this.getUIContext().getRouter();
  context = this.getUIContext().getHostContext();
  @State videoPath: string = ''; // 视频路径

  // 唤起相机录像
  startCameraPicker() {
    try {
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK, // 后置摄像头
        videoDuration: 15 // 录制的最大时长，单位秒
      };
      // 只处理录像
      cameraPicker.pick(this.context, [cameraPicker.PickerMediaType.VIDEO], pickerProfile).then((pickerResult) => {
        console.info('the pick pickerResult is:' + JSON.stringify(pickerResult));
        this.videoPath = pickerResult.resultUri
      })
    } catch (error) {
      let err = error as BusinessError;
      console.error(`the pick call failed. error code: ${err.code}, error msg: ${err.message}`);
    }
  }

  // 选择相册视频
  chooseVideo() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions)
      .then((photoSelectResult) => {
        console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
        this.videoPath = photoSelectResult.photoUris[0]
      }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Row() {
        Button('拉起相机录像').width('100%')
          .type(ButtonType.Normal).fontSize(17)
          .fontColor(Color.White).backgroundColor($r('app.color.rose'))
          .onClick(() => {
            this.startCameraPicker() // 唤起相机录像
            //this.chooseVideo() // 选择相册视频
          })
      }.width('100%').padding(4)
      Video({ src: this.videoPath }).width('100%').layoutWeight(1)
        .objectFit(ImageFit.Contain) // 组件区域包含整个视频画面
        .autoPlay(true) // 是否自动轮播
        .controls(true) // 是否显示控制条
        .loop(true) // 是否循环轮播
      Row() {
        Button('取消').width('100%').layoutWeight(1).margin(2)
          .type(ButtonType.Normal).fontSize(17)
          .fontColor(Color.White).backgroundColor(Color.Gray)
          .onClick(() => {
            this.router.back() // 返回到前一个页面
          })
        Button('下一步').width('100%').layoutWeight(1).margin(2)
          .type(ButtonType.Normal).fontSize(17)
          .fontColor(Color.White).backgroundColor($r('app.color.rose'))
          .onClick(() => {
            this.router.pushUrl({
              url: 'short/ShortEditPage',
              params: {
                path: this.videoPath
              }
            })
          })
      }
      .width('100%').padding(2)
      .visibility(this.videoPath?Visibility.Visible:Visibility.Hidden)
    }
    .width('100%').height('100%')
  }
}