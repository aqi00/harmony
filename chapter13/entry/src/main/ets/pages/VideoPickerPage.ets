import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Entry
@Component
struct VideoPickerPage {
  @State videoPath: string = ''; // 视频路径
  @State previewUri: Resource = $r('app.media.startIcon'); // 预览图
  @State isStart: boolean = false; // 是否开始播放
  @State isPause: boolean = true; // 是否暂停播放
  private videoController = new VideoController(); // 视频控制器

  // 选择相册视频
  chooseVideo() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions)
      .then((photoSelectResult) => {
        console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
        this.videoPath = photoSelectResult.photoUris[0] // 视频路径
      }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('到相册选择视频').width('100%').fontSize(18)
        .onClick(() => {
          this.chooseVideo() // 选择相册视频
        })
      Video({
        src: this.videoPath, // 视频路径
        previewUri: this.previewUri, // 预览图路径
        controller: this.videoController // 视频控制器
      }).width('100%').layoutWeight(1)
        .objectFit(ImageFit.Contain) // 组件区域包含整个视频画面
        .autoPlay(true) // 是否自动播放
        .controls(true) // 是否显示控制条
        .onStart(() => {
          this.isStart = true
          this.isPause = false
          console.info('onStart')
        })
        .onPause(() => {
          this.isPause = true
          console.info('onPause')
        })
        .onFinish(() => {
          console.info('onFinish')
        })
        .onError(() => {
          console.info('onError')
        })
        .onStop(() => {
          this.isStart = false
          console.info('onStop')
        })
        // .onPrepared((e?: DurationObject) => {
        //   if (e != undefined) {
        //     console.info('onPrepared is ' + e.duration)
        //   }
        // })
        // .onSeeking((e?: TimeObject) => {
        //   if (e != undefined) {
        //     console.info('onSeeking is ' + e.time)
        //   }
        // })
        // .onSeeked((e?: TimeObject) => {
        //   if (e != undefined) {
        //     console.info('onSeeked is ' + e.time)
        //   }
        // })
        // .onUpdate((e?: TimeObject) => {
        //   if (e != undefined) {
        //     console.info('onUpdate is ' + e.time)
        //   }
        // })
      Row() {
        Button(this.isStart?'停止':'开始').fontSize(18).layoutWeight(1)
          .onClick(() => {
            if (this.isStart) {
              this.videoController.stop() // 停止播放
            } else {
              this.videoController.start() // 开始播放
            }
          })
        Button(this.isPause?'恢复':'暂停').fontSize(18).layoutWeight(1)
          .onClick(() => {
            if (this.isPause) {
              this.videoController.start() // 开始播放
            } else {
              this.videoController.pause() // 暂停播放
            }
          })
      }
    }
    .width('100%')
  }
}