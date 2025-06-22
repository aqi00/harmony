import { componentSnapshot } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct CanvasSignaturePage {
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private canvas: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private canvasWidth = 0; // 画布宽度
  private canvasHeight = 0; // 画布高度

  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED,
    text: SaveDescription.SAVE_IMAGE,
    buttonType: ButtonType.Capsule
  };

  // 把像素图保存到相册
  savePixelMapToAlbum(pixmap: image.PixelMap) {
    let helper = photoAccessHelper.getPhotoAccessHelper(this.context);
    // 只能在安全控件SaveButton中调用
    helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', (err, uri) => {
      if (uri !== undefined) {
        console.info('createAsset uri: ' + uri);
        let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        let imagePackerApi = image.createImagePacker();
        let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 80 };

        imagePackerApi.packToFile(pixmap, file.fd, packOpts, (err: BusinessError) => {
          if (err) {
            console.error(`Failed to pack the image to file.code ${err.code},message is ${err.message}`);
          } else {
            imagePackerApi.release((err: BusinessError) => {
              if (err) {
                console.error(`Failed to release the image source instance.code ${err.code},message is ${err.message}`);
              } else {
                console.info('Succeeded in releasing the image source instance.');
                fileIo.close(file.fd);
                this.promptAction.showToast({ message: '已将签名图片已保存至相册' });
              }
            })
          }
        })
      } else {
        console.error(`createAsset failed, error: ${err.code}, ${err.message}`);
      }
    });
  }

  build() {
    Column() {
      Button('清空画布').width('100%').fontSize(18)
        .onClick(() => {
          this.canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
        })
      Canvas(this.canvas).width('100%').height(300).id('cv_signature')
        .onTouch((event?: TouchEvent) => {
          if (event != undefined && event.touches != undefined) {
            let item = event.touches[0]
            if (item.type == TouchType.Down) { // 按下动作
              this.canvas.strokeStyle = '#ff0000' // 线条颜色
              this.canvas.lineWidth = this.getUIContext().vp2px(1) // 线条宽度
              this.canvas.beginPath() // 创建新的绘制路径
              this.canvas.moveTo(item.x, item.y) // 移动到指定点
            } else if (item.type == TouchType.Move) { // 移动动作
              this.canvas.lineTo(item.x, item.y) // 两点间拉根线
              this.canvas.stroke() // 描绘路径上的线条
            } else if (item.type == TouchType.Up) { // 提起动作
              this.canvas.lineTo(item.x, item.y) // 两点间拉根线
              this.canvas.stroke() // 描绘路径上的线条
            }
          }
        })
        // 组件尺寸或者组件位置发生变化时触发
        .onAreaChange((oldValue: Area, newValue: Area) => {
          console.info(`onAreaChange, oldValue is ${JSON.stringify(oldValue)} value is ${JSON.stringify(newValue)}`)
          this.canvasWidth = Number(newValue.width)
          this.canvasHeight = Number(newValue.height)
          this.canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
        })
      // 创建安全控件按钮，不得另外设置width、fontSize等属性
      SaveButton(this.saveButtonOptions)
        .onClick(async (event, result: SaveButtonOnClickResult) => {
          if (result == SaveButtonOnClickResult.SUCCESS) {
            this.getUIContext().getComponentSnapshot().get('cv_signature', (error: Error, pixmap: image.PixelMap) => {
              if (error) {
                console.info("error: " + JSON.stringify(error))
                return;
              }
              this.savePixelMapToAlbum(pixmap) // 把像素图保存到相册
            }, {scale : 1, waitUntilRenderFinished : true})
          }
        })
    }
    .width('100%').height('100%')
  }

}