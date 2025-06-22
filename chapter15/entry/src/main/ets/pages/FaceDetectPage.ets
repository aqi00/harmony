import { faceDetector } from '@kit.CoreVisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';

@Entry
@Component
struct FaceDetectPage {
  context = this.getUIContext();
  @State pixelMap: PixelMap | undefined = undefined; // 待识别像素图
  @State result: string = '检测结果在这里'; // 检测结果
  private canvas: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private canvasWidth = 0; // 画布宽度
  private canvasHeight = 0; // 画布高度
  private imageWidth = 0; // 图像宽度
  private imageHeight = 0; // 图像高度
  private lastRect?: faceDetector.FaceRectangle; // 上次检测的人脸矩形框

  // 选择相册图片
  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      this.analyzeImage(photoSelectResult.photoUris[0]) // 分析人脸图像
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  // 清空画布
  clearCanvas() {
    if (this.lastRect) { // 清除上次的人脸方框
      this.canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
    }
  }

  // 描绘人脸方框
  drawCanvas(rect: faceDetector.FaceRectangle) {
    this.canvas.strokeStyle = '#ff0000'
    this.canvas.lineWidth = this.context.vp2px(1)
    let leftEdge = rect.left/this.imageWidth*this.canvasWidth
    let topEdge = rect.top/this.imageWidth*this.canvasWidth -
      (this.imageHeight*this.canvasWidth/this.imageWidth-this.canvasHeight)/2
    let width = rect.width/this.imageWidth*this.canvasWidth
    let height = rect.height/this.imageWidth*this.canvasWidth
    console.info(`this.imageWidth=${this.imageWidth}, this.imageHeight=${this.imageHeight}`)
    console.info(`leftEdge=${leftEdge}, topEdge=${topEdge}, width=${width}, height=${height}`)
    this.canvas.strokeRect(leftEdge, topEdge, width, height) // 描绘人脸方框
  }

  // 分析人脸图像
  analyzeImage(uri: string) {
    let file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    console.info('MS_LITE_LOG: file fd: ' + file.fd);
    // 通过PixelMap预处理
    let imageSource = image.createImageSource(file.fd);
    let imageInfo = imageSource.getImageInfoSync()
    this.imageWidth = imageInfo.size.width
    this.imageHeight = imageInfo.size.height
    this.pixelMap = imageSource.createPixelMapSync() // 把图片文件转换为像素图
    this.result = '';
    console.info('this.pixelMap:', this.pixelMap);
    this.clearCanvas() // 清空画布
  }

  // 解析人像结果
  parserResult(data: faceDetector.Face[]) {
    for (let i=0; i<data.length; i++) {
      let face = data[i]
      let ratio = (face.probability*100).toFixed(0) + '%'
      this.result = `第${i+1}个人脸的可能性为${ratio}，左边界为${face.rect.left}，` +
        `上边界为${face.rect.top}，宽度为${face.rect.width}，高度为${face.rect.height}\n`
      this.drawCanvas(face.rect) // 描绘人脸方框
      this.lastRect = face.rect
    }
  }

  // 开始检测人脸
  detectFace() {
    if (!this.pixelMap) {
      console.error('Failed to detect face.');
      return;
    }
    //faceDetector.init() // 初始化人脸检测器
    let visionInfo: faceDetector.VisionInfo = { pixelMap: this.pixelMap };
    // 开始检测人脸
    faceDetector.detect(visionInfo).then((data: faceDetector.Face[]) => {
        if (data.length === 0) {
          this.result = '未找到人脸';
        } else {
          console.info('faceString data is ' + JSON.stringify(data));
          this.parserResult(data) // 解析人像结果
        }
      }).catch((error: BusinessError) => {
        console.error(`Face detection failed. Code: ${error.code}, message: ${error.message}`);
        this.result = `Error: ${error.message}`;
      });
    //faceDetector.release() // 释放人脸检测器
  }

  build() {
    Column() {
      Button('请选择图片').width('100%').fontSize(18)
        .onClick(() => {
          this.choosePhoto() // 选择相册图片
        })

      Stack() {
        Image(this.pixelMap).width('100%').height('100%')
        Canvas(this.canvas)
          .width('100%').height('100%').backgroundColor(Color.Transparent)
            // 组件尺寸或者组件位置发生变化时触发
          .onAreaChange((oldValue: Area, newValue: Area) => {
            console.info(`onAreaChange, oldValue is ${JSON.stringify(oldValue)} value is ${JSON.stringify(newValue)}`)
            this.canvasWidth = Number(newValue.width)
            this.canvasHeight = Number(newValue.height)
            console.info(`canvasWidth=${newValue.width}, canvasHeight=${newValue.height}`)
          })
      }
      .width('100%').height('40%')

      Button('开始检测人脸').width('100%').fontSize(18)
        .onClick(() => {
          this.detectFace() // 开始检测人脸
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }

}