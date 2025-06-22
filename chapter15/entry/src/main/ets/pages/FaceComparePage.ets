import { faceComparator } from '@kit.CoreVisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';

@Entry
@Component
struct FaceComparePage {
  @State result: string = '比对结果在这里'; // 比对结果
  @State imageSample: Resource = $r('app.media.chose_pic');
  @State firstUri: string = ''; // 第一张人脸图片的文件路径
  @State secondUri: string = ''; // 第二张人脸图片的文件路径

  // aboutToAppear() {
  //   faceComparator.init(); // 初始化人脸比对器
  // }
  //
  // aboutToDisappear() {
  //   faceComparator.release() // 释放人脸比对器
  // }

  // 选择相册图片
  choosePhoto(seq: number) {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      if (seq == 1) { // 第一张图片
        this.firstUri = photoSelectResult.photoUris[0]
      } else { // 第二张图片
        this.secondUri = photoSelectResult.photoUris[0]
      }
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  // 比对人脸相似度
  compareFace() {
    let fisrtFile = fileIo.openSync(this.firstUri, fileIo.OpenMode.READ_ONLY);
    console.info('fisrtFile.fd: ' + fisrtFile.fd)
    let fisrtSource = image.createImageSource(fisrtFile.fd);
    let firstPixelMap = fisrtSource.createPixelMapSync();
    let secondFile = fileIo.openSync(this.secondUri, fileIo.OpenMode.READ_ONLY);
    console.info('secondFile.fd: ' + secondFile.fd)
    let secondSource = image.createImageSource(secondFile.fd);
    let secondPixelMap = secondSource.createPixelMapSync();
    let firstVisionInfo: faceComparator.VisionInfo = { pixelMap: firstPixelMap };
    let secondVisionInfo: faceComparator.VisionInfo = { pixelMap: secondPixelMap };
    // 开始比对人脸的相似程度
    faceComparator.compareFaces(firstVisionInfo, secondVisionInfo)
      .then((data: faceComparator.FaceCompareResult) => {
        let ratio = (data.similarity*100).toFixed(1) + '%'
        console.info('ratio: '+ ratio)
        this.result = `相似度为${ratio}，${data.isSamePerson?'是':'不是'}同一个人。`
        //this.result = '相似度为'+ ratio+((data.isSamePerson)?'，是':'，不是')+ '同一个人。';
      })
      .catch((error: BusinessError) => {
        console.error(`Face comparison failed. Code: ${error.code}, message: ${error.message}`);
      });
  }

  build() {
    Column() {
      Row() {
        Stack() {
          Shape() {
            Rect().width('100%').height('100%').stroke(Color.Gray).fill(Color.White)
          }
          Image(this.imageSample).width('50%').height('50%')
          Image(this.firstUri).width('100%').height('100%')
        }
        .height('100%').layoutWeight(1).padding(3)
        .onClick(() => {
          this.choosePhoto(1) // 选择相册图片
        })
        Stack() {
          Shape() {
            Rect().width('100%').height('100%').stroke(Color.Gray).fill(Color.White)
          }
          Image(this.imageSample).width('50%').height('50%')
          Image(this.secondUri).width('100%').height('100%')
        }
        .height('100%').layoutWeight(1).padding(3)
        .onClick(() => {
          this.choosePhoto(2) // 选择相册图片
        })
      }
      .width('100%').height(300)
      Button('开始比对').width('100%').fontSize(18).margin(3)
        .onClick(() => {
          if (this.firstUri.length==0 || this.secondUri.length==0) {
            this.result = '请先选择待比对的图片'
            return
          }
          this.compareFace() // 比对人脸相似度
        })
      Text(this.result).width('100%').fontSize(18).padding(2)
    }
    .width('100%').height('100%').padding(3)
  }

}