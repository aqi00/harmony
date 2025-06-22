import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';

@Entry
@Component
struct ImageInfoPage {
  @State message: string = ''; // 获取结果
  @State imagePath: string = ''; // 图片路径
  private pixelFormatArray = ['未知格式', '？？格式', 'RGB_565格式', 'RGBA_8888格式',
    'BGRA_8888格式', 'RGB_888格式','ALPHA_8格式', 'RGBA_F16格式','NV21格式', 'NV12格式',];
  private alphaTypeArray = ['未知透明度', '图片不透明', 'RGB预乘alpha', 'RGB非预乘alpha'];

  // 获取图片信息
  parserImageInfo() {
    console.info('imagePath: '+this.imagePath)
    // 注意：createImageSource方法传入路径字符串当前仅支持应用沙箱路径
    //let imageSource = image.createImageSource(this.imagePath);

    // 调用fileIo.openSync接口，通过uri打开这个文件得到fd
    let file = fileIo.openSync(this.imagePath, fileIo.OpenMode.READ_ONLY);
    console.info('MS_LITE_LOG: file fd: ' + file.fd);
    let imageSource = image.createImageSource(file.fd);

    let imageInfo = imageSource.getImageInfoSync()
    this.message = `图片分辨率为${imageInfo.size.width}x${imageInfo.size.height}，` +
      `格式类型为${imageInfo.mimeType}，` +
      `像素格式为${this.pixelFormatArray[imageInfo.pixelFormat]}，` +
      `透明度类型为${this.alphaTypeArray[imageInfo.alphaType]}。`
  }

  // 选择相册图片
  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions)
      .then((photoSelectResult) => {
        console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
        this.imagePath = photoSelectResult.photoUris[0]
        this.parserImageInfo() // 获取图片信息
      }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('到相册选择图片').width('100%').fontSize(18)
        .onClick(() => {
          this.choosePhoto() // 选择相册图片
        })
      Image(this.imagePath).height(300).objectFit(ImageFit.Contain)
      Text(this.message).width('100%').padding(5).fontSize(18)
    }
    .width('100%').height('100%')
  }
}