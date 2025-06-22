import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Entry
@Component
struct PhotoPickerPage {
  @State imagePath: string = ''; // 图片路径

  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions)
      .then((photoSelectResult) => {
        console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
        this.imagePath = photoSelectResult.photoUris[0] // 选中的图片路径
      }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('到相册选择图片').fontSize(18).width('100%')
        .onClick(() => {
          this.choosePhoto() // 选择相册图片
        })
      Image(this.imagePath).width('100%').objectFit(ImageFit.Contain)
    }
    .width('100%').padding(5)
  }
}