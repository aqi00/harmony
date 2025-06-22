import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { promptAction } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { request, BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../constant/Constants';

@Entry
@Component
struct HttpUploadPage {
  promptAction = this.getUIContext().getPromptAction();
  // 注意这里的URL地址要换成读者在自己WiFi环境下的IP和端口
  private URL_UPLOAD = Constants.URL_PREFIX + 'register'; // 注册接口的完整地址
  @State user_name: string = ''; // 用户名
  @State password: string = ''; // 密码
  @State result: string = ''; // 文件上传结果
  @State imagePath: string | Resource = $r('app.media.add_pic');
  private dstPath: string = ''; // 目标文件路径
  // 注意：
  // 1、文件目录要从UIAbilityContext获取，不能从getApplicationContext获取
  // 2、上传时要把文件路径转为'internal://cache/文件名'的形式
  //private context = this.context.getApplicationContext();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  // 把相册图片复制到应用的缓存目录下
  copyFile() {
    let fileName = this.imagePath.toString().split('/').pop() as string;
    console.info(`file name: ${fileName}`);
    this.dstPath = `${this.context.cacheDir}/${fileName}`
    console.info(`dstPath name: ${this.dstPath}`);
    let srcFile = fileIo.openSync(this.imagePath.toString());
    let dstFile = fileIo.openSync(this.dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.copyFileSync(srcFile.fd, dstFile.fd); // 同步复制文件
    fileIo.closeSync(srcFile);
    fileIo.closeSync(dstFile);
  }

  // 调用服务端的注册接口上传图片
  register() {
    let fileName = this.imagePath.toString().split('/').pop() as string
    let suffix = fileName.split('.').pop() as string
    let realPath = 'internal://cache/' + fileName
    console.info('realPath: ' + realPath)
    let file: request.File = { filename: fileName, name: `image`, uri: realPath, type: suffix }
    // 设定上传配置
    let config: request.UploadConfig = {
      method: 'POST', // 请求方式
      url: this.URL_UPLOAD, // 请求地址
      header: { 'Accept': '*/*' }, // 请求包头
      files: [file], // 待上传的文件列表
      data: [{ name: 'username', value: this.user_name}, { name: 'password', value: this.password}]
    }
    let uploadTask: request.UploadTask; // 上传任务
    // 请求上传本地文件
    // uploadFile接口传入参数localPath只能设置为context.cacheDir目录下的文件路径，所以上传前需要先将文件复制到context.cacheDir目录下
    request.uploadFile(this.context, config).then(data => {
      uploadTask = data;
      // 订阅上传进度事件
      uploadTask.on('progress', (size, tot) => {
        let ratio = Math.round(100.0*size/tot)
        this.result += `上传进度：${ratio}%\n`
      })
      // 订阅上传完成事件
      uploadTask.on('complete', () => {
        this.result += '上传完成\n'
      })
    }).catch((err: BusinessError) => {
      console.error('Failed to request the upload. Cause: ' + JSON.stringify(err));
    })
  }

  build() {
    Column() {
      Row() {
        Text('用户名：').fontSize(18)
        TextInput({ text: $$this.user_name, placeholder: '请输入用户名' })
          .layoutWeight(1).height(40).fontSize(18).type(InputType.Normal)

      }.margin(5)
      Row() {
        Text('密　码：').fontSize(18)
        TextInput({ text: $$this.password, placeholder: '请输入密码' })
          .layoutWeight(1).height(40).fontSize(18)
          .type(InputType.Password).maxLength(8).showPasswordIcon(true)
          .inputFilter('[a-zA-Z0-9~!@#$%^&*()_+-=]')
      }.margin(5)
      Row() {
        Text('头　像：').fontSize(18).height('100%')
        Image(this.imagePath).width(100).height('100%').objectFit(ImageFit.Contain)
          .onClick(() => {
            this.choosePhoto() // 选择相册图片
          })
      }.padding(5).width('100%').height(100).justifyContent(FlexAlign.Start)
      Button('注册').fontSize(18).width('100%')
        .onClick(() => {
          if (!this.imagePath.toString().startsWith('file:')) {
            this.promptAction.showToast({message: '请选择一张头像图片'})
            return
          }
          this.copyFile() // 把相册图片复制到应用的缓存目录下
          this.register() // 调用服务端的注册接口上传图片
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%')
  }

  // 选择相册图片
  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      this.imagePath = photoSelectResult.photoUris[0]
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }
}