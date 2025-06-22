import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct PhotoSavePage {
  promptAction = this.getUIContext().getPromptAction();
  context = this.getUIContext().getHostContext() as common.Context;
  @State image: Resource = $r('app.media.startIcon')

  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED,
    text: SaveDescription.SAVE_IMAGE,
    buttonType: ButtonType.Capsule
  };

  saveImageToAlbum(image: Resource) {
    let helper = photoAccessHelper.getPhotoAccessHelper(this.context);
    // 只能在安全控件SaveButton中调用
    helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', (err, uri) => {
      if (uri !== undefined) {
        console.info('createAsset uri: ' + uri);
        this.context.resourceManager.getMediaContent(image.id, (err: BusinessError, value: Uint8Array) => {
          if (err) {
            console.error(`getMediaContent error: : ${err.code}, ${err.message}`);
          } else {
            let media = value.buffer;
            let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
            fileIo.writeSync(file.fd, media);
            fileIo.closeSync(file.fd);
            this.promptAction.showToast({ message: '已保存至相册！' });
          }
        });
      } else {
        console.error(`createAsset failed, error: ${err.code}, ${err.message}`);
      }
    });
  }

  build() {
    Column() {
      Image(this.image).width('100%').height(100).objectFit(ImageFit.Contain)
      // 创建安全控件按钮，不得另外设置width、fontSize等属性
      SaveButton(this.saveButtonOptions)
        .onClick(async (event, result: SaveButtonOnClickResult) => {
          if (result == SaveButtonOnClickResult.SUCCESS) {
            this.saveImageToAlbum(this.image)
          }
        })
    }
    .width('100%').height('100%')
  }
}