import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { promptAction } from '@kit.ArkUI';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { request } from '@kit.BasicServicesKit';
import { Constants } from '../constant/Constants';

@Entry
@Component
struct InfoEditPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  // 注意这里的URL地址要换成读者在自己WiFi环境下的IP和端口
  private url: string = Constants.URL_PREFIX + 'joinNearby'; // 加入附近的人接口的完整地址
  @State name: string = '';
  private isMale: boolean = true;
  @State phone: number = 0;
  @State imagePath: string | Resource = $r('app.media.add_pic');
  @State address: string = '';
  @State info: string = '';
  @State isUploading: boolean = false; // 是否正在上传
  @State index: number = 0;
  private loveArray: Array<SelectOption> = [
    { value: '唱歌' }, { value: '跳舞' }, { value: '绘画' },
    { value: '弹琴' }, { value: '摄影' }, { value: '出售闲置物品' }
  ];
  private latitude: number = 0;
  private longitude: number = 0;

  private dataPref?: preferences.Preferences; // 首选项实例
  aboutToAppear() {
    let options: preferences.Options = { name: 'user_store' };
    this.dataPref = preferences.getPreferencesSync(this.context, options);
  }

  onPageShow() {
    let params = this.router.getParams() as Record<string, Object>;
    this.latitude = params?.['latitude'] as number
    this.longitude = params?.['longitude'] as number
    this.address = params?.['address'] as string
    console.info(`latitude=${this.latitude}, longitude=${this.longitude}, address=${this.address}`)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('昵称：').fontSize(18)
          TextInput({ text: $$this.name, placeholder: '请输入您的昵称' })
            .fontSize(18).type(InputType.Normal).layoutWeight(1)
        }.width('100%').padding(5)
        Row() {
          Text('性别：').fontSize(18)
          Radio({ value: 'radio1', group: 'radioGroup' })
            .checked(true)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.isMale = true
              }
            })
          Text('男').fontSize(18)
          Blank().layoutWeight(1)
          Radio({ value: 'radio2', group: 'radioGroup' })
            .checked(false)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.isMale = false
              }
            })
          Text('女').fontSize(18)
          Blank().layoutWeight(1)
        }.width('100%').padding(5)
        Row() {
          Text('手机：').fontSize(18)
          TextInput({ text: $$this.phone, placeholder: '请输入您的手机号码' })
            .fontSize(18).type(InputType.Number)
            .layoutWeight(1).maxLength(11).inputFilter('[0-9\.]')
        }.width('100%').padding(5)
        Row() {
          Text('爱好：').fontSize(18)
          Select(this.loveArray).font({ size: 18 }).layoutWeight(1)
            .selected($$this.index).value(this.loveArray[this.index].value)
        }.width('100%').padding(5)
        Row() {
          Text('地址：').fontSize(18)
          TextInput({ text: $$this.address })
            .fontSize(18).type(InputType.Normal).layoutWeight(1)
        }.width('100%').padding(5)
        Row() {
          Text('头像：').fontSize(18)
          Image(this.imagePath).width(100).height(100).objectFit(ImageFit.Contain)
            .onClick(() => {
              this.choosePhoto() // 选择相册图片
            })
        }.width('100%').padding(5)
        Column() {
          Text('要发布的信息：').width('100%').padding(5).fontSize(17)
          TextArea({text:$$this.info, placeholder: '请输入要发布的信息'})
            .width('100%').height(150).fontSize(17).type(TextAreaType.NORMAL)
        }.width('100%').padding(5)
        Button('确定').fontSize(18).width('100%')
          .onClick(() => {
            if (this.name.length == 0) {
              this.promptAction.showToast({message: '请先输入您的昵称'})
            } else if (this.phone == 0) {
              this.promptAction.showToast({message: '请先输入您的手机号码'})
            } else if (this.info.length == 0) {
              this.promptAction.showToast({message: '请先输入要发布的信息'})
            } else if ((typeof this.imagePath) != 'string') {
              this.promptAction.showToast({message: '请先选择您的头像'})
            } else {
              this.saveUserInfo() // 保存用户信息
            }
          })
      }
      .width('100%').height('100%')
      if (this.isUploading) {
        Column() {
          Column() {
            LoadingProgress().width(80).height(80).color(Color.Black)
            Text('正在保存位置信息，请稍等……').fontSize(16)
          }
          .width('40%').padding({bottom:15})
          .backgroundColor(Color.White).justifyContent(FlexAlign.Center)
        }
        .width('100%').height('100%')
        .backgroundColor('#40000000').justifyContent(FlexAlign.Center)
      }
    }.width('100%').height('100%')
  }

  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      this.processPortrait(photoSelectResult.photoUris[0])
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  processPortrait(path: string) {
    let fileName = path.toString().split('/').pop() as string
    let suffix = (fileName.split('.').pop() as string).toLowerCase()
    let fileFormat = suffix=='png' ? 'image/png' : 'image/jpeg'
    let file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
    console.info(`fileName: ${fileName}, format:${fileFormat}, fileFd: ${file.fd}`);
    let imageSource = image.createImageSource(file.fd);
    imageSource.createPixelMap().then((pixelMap) => {
      let fenmu = 400
      let size = pixelMap.getImageInfoSync().size
      let ratio = 1
      if (size.width>fenmu && size.height>fenmu) {
        ratio = Math.round(size.width/fenmu) + 1
        console.info('ratio='+ratio)
        pixelMap.scaleSync(1.0/ratio, 1.0/ratio) // 填缩放的倍数
      }
      if (size.width>fenmu || size.height>fenmu) {
        let minScope = Math.floor(Math.min(size.width/ratio, size.height/ratio))
        console.info('minScope='+minScope)
        size = {width: minScope, height: minScope}
        let region: image.Region = { x: 0, y: 0, size: size }
        pixelMap.cropSync(region) // 填裁剪的区域
      }
      this.savePortrait(fileName, pixelMap) // 保存裁剪后的头像
    })
  }

  // 注意：
  // 1、文件目录要从UIAbilityContext获取，不能从getApplicationContext获取
  // 2、上传时要把文件路径转为'internal://cache/文件名'的形式
  //private context = this.context.getApplicationContext();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext

  savePortrait(fileName: string, pixelMap: image.PixelMap) {
    console.info(`image file name: ${fileName}`);
    let imagePath = `${this.context.cacheDir}/${fileName}`
    console.info(`imagePath name: ${imagePath}`);
    let size = pixelMap.getImageInfoSync().size
    console.info(`width: ${size.width}, height: ${size.height}`);
    try {
      let dstFile = fileIo.openSync(imagePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      // 转存为图片
      let imagePackerApi: image.ImagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 90 };
      imagePackerApi.packToFile(pixelMap, dstFile.fd, packOpts, (err: BusinessError) => {
        fileIo.closeSync(dstFile);
        if (err) {
          console.error(`Failed to pack the image to file.code ${err.code},message is ${err.message}`);
        } else {
          console.info('Succeeded in packing the image to file.');
          // Image组件不能直接传入应用沙箱路径，需要传入应用沙箱uri
          // https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs-V5/faqs-arkui-154-V5
          this.imagePath = fileUri.getUriFromPath(imagePath)
        }
      })
    } catch (e) {
      console.error(`save cover failed ${e.message}`);
    }
  }

  upload(callback: (result: number, error: string) => void) {
    let imageFileName = this.imagePath.toString().split('/').pop() as string
    let imageSuffix = imageFileName.split('.').pop() as string
    let imageRealPath = 'internal://cache/' + imageFileName
    console.info('imageRealPath: ' + imageRealPath)
    let imageFile: request.File = { filename: imageFileName,
      name: `image`, uri: imageRealPath, type: 'image/'+imageSuffix }
    let loveDesc = this.loveArray[this.index].value.toString()
    // 设定上传配置
    let config: request.UploadConfig = {
      method: 'POST', // 请求方式
      url: this.url, // 请求地址
      header: { 'Accept': '*/*' }, // 请求包头
      files: [imageFile], // 待上传的文件列表
      data: [{ name: 'name', value: this.name}, { name: 'sex', value: this.isMale?'0':'1'},
        { name: 'phone', value: this.phone+''}, { name: 'love', value: loveDesc},
        { name: 'info', value: this.info}, { name: 'address', value: this.address},
        { name: 'latitude', value: this.latitude+''}, { name: 'longitude', value: this.longitude+''}]
    }
    let uploadTask: request.UploadTask; // 上传任务
    // 请求上传本地文件
    // uploadFile接口传入参数localPath只能设置为context.cacheDir目录下的文件路径，所以上传前需要先将文件复制到context.cacheDir目录下
    request.uploadFile(this.context, config).then(data => {
      uploadTask = data;
      // 订阅上传进度事件
      uploadTask.on('progress', (size, tot) => {
        let ratio = Math.round(100.0*size/tot)
        console.info(`上传进度：${ratio}%`)
      })
      // 订阅上传完成事件
      uploadTask.on('complete', () => {
        console.info(`上传完成`)
        callback(0, '') // 回调通知上传成功
      })
    }).catch((err: BusinessError) => {
      console.error('Failed to request the upload. Cause: ' + JSON.stringify(err));
      callback(-1, JSON.stringify(err)) // 回调通知上传失败
    })
  }

  saveUserInfo() {
    this.isUploading = true
    this.upload((result: number, error: string) => {
      this.isUploading = false
      if (result == 0) { // 保存成功
        this.dataPref?.putSync('commitMyInfo', 'true')
        this.dataPref?.flush() // 持久化缓存中的首选项数据，避免页面太快跳转导致首选项没有及时提交
        this.promptAction.showToast({message: '成功保存您的位置信息'})
        setTimeout(() => {
          this.router.clear();
          this.router.replaceUrl({ url: 'nearby/NearbyPage' }, router.RouterMode.Single)
        }, 200)
      } else { // 保存失败
        this.promptAction.showToast({message: '保存位置信息失败：'+error})
      }
    })
  }

}