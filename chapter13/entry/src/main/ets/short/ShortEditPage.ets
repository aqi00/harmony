import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { request } from '@kit.BasicServicesKit';
import { Utils } from '../utils/Utils';
import { GlobalExtractor } from '../utils/GlobalExtractor';
import { Constants } from '../constant/Constants';

@Entry
@Component
struct ShortEditPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  // 注意这里的URL地址要换成读者在自己WiFi环境下的IP和端口
  private url: string = Constants.URL_PREFIX + 'commitVideo'; // 提交视频的完整地址
  @State videoPath: string = ''; // 视频路径
  @State date: string = ''; // 拍摄日期
  @State address: string = ''; // 拍摄地点
  @State label: string = ''; // 视频标签
  @State desc: string = ''; // 视频描述
  @State pixelMap: PixelMap | undefined = undefined; // 像素图
  @State isUploading: boolean = false; // 是否正在上传
  private selectedDate: Date = new Date(); // 选择的日期
  private coverPos = 0; // 封面位置
  private coverSeq = 0; // 封面序号
  private imagePath: string =''; // 封面图路径

  private extractor: GlobalExtractor = GlobalExtractor.getInstance();
  onPageHide() {
    this.extractor.release() // 释放提取器
  }

  onPageShow() {
    this.extractor.create() // 创建提取器
    this.date = Utils.getFormatDate(this.selectedDate)
    let params = this.router.getParams() as Record<string, Object>;
    let pos = params?.['pos'] as number
    console.info('pos='+pos)
    if (!isNaN(pos)) {
      this.coverPos = pos
    }
    let seq = params?.['seq'] as number
    console.info('seq='+seq)
    if (!isNaN(seq)) {
      this.coverSeq = seq
    }
    let path = params?.['path'] as string
    console.info('path='+path)
    if (path) {
      this.videoPath = path
    }
    console.info('coverPos='+this.coverPos+', videoPath='+this.videoPath)
    if (this.videoPath) {
      setTimeout(() => {
        // 获取视频信息
        this.extractor.getVideoInfo(this.videoPath, (fd, metadata) => {
          // 获取视频缩略图
          this.extractor.getThumbnail(fd, metadata, this.coverPos, (pixelMap) => {
            this.pixelMap = pixelMap;
            this.saveCover() // 保存封面图片
          })
        })
      }, 100)
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            Text('请选择日期').width('100%').fontSize(17).padding(5)
            Text(this.date).fontSize(17).padding(5)
              .onClick(() => {
                this.getUIContext().showDatePickerDialog({
                  start: new Date('2000-1-1'),
                  end: new Date('2100-12-31'),
                  selected: this.selectedDate, // 默认的选中日期
                  showTime:false, // 是否显示时间
                  onDateAccept: (value: Date) => {
                    this.selectedDate = value
                    this.date = Utils.getFormatDate(this.selectedDate)
                  }
                })
              })
            Text('请填写地点').width('100%').fontSize(17).padding(5)
            TextArea({text:$$this.address}).width('100%').layoutWeight(1)
              .fontSize(17).type(TextAreaType.NORMAL)
            Text('请输入标签').width('100%').fontSize(17).padding(5)
            TextArea({text:$$this.label}).width('100%').layoutWeight(1)
              .fontSize(17).type(TextAreaType.NORMAL)
          }.height('100%').layoutWeight(1).padding({left:3, right:3, bottom:5})
          Column() {
            Image(this.pixelMap)
              .width(135).layoutWeight(1).objectFit(ImageFit.Contain)
            Button('选封面').width('100%').margin({ top:5, bottom:5 })
              .type(ButtonType.Normal).fontSize(17)
              .fontColor(Color.White).backgroundColor(Color.Gray)
              .onClick(() => {
                this.router.pushUrl({
                  url: 'short/ShortCoverPage',
                  params: {
                    path: this.videoPath,
                    pos: this.coverPos,
                    seq: this.coverSeq,
                    lastUrl: this.router.getState().path + this.router.getState().name
                  }
                })
              })
          }.height('100%').width(145).padding(3)
        }.width('100%').height(300).padding(3)
        Column() {
          Text('请填写视频描述').width('100%').fontSize(17).padding(5)
          TextArea({text:$$this.desc}).width('100%').height(150)
            .fontSize(17).type(TextAreaType.NORMAL)
        }.width('100%').padding({ left:6, right:6 })
        Row() {
          Button('返回').width('100%').layoutWeight(1).margin(3)
            .type(ButtonType.Normal).fontSize(17)
            .fontColor(Color.White).backgroundColor(Color.Gray)
            .onClick(() => {
              this.router.back() // 返回到前一个页面
            })
          Button('发布').width('100%').layoutWeight(1).margin(3)
            .type(ButtonType.Normal).fontSize(17)
            .fontColor(Color.White).backgroundColor($r('app.color.rose'))
            .onClick(() => {
              if (this.address.length == 0) {
                this.promptAction.showToast({message: '请先输入视频拍摄地址'})
              } else if (this.label.length == 0) {
                this.promptAction.showToast({message: '请先输入视频的标签'})
              } else if (this.desc.length == 0) {
                this.promptAction.showToast({message: '请先输入视频的描述'})
              } else {
                this.publishVideo() // 发布短视频
              }
            })
        }.width('100%').padding(3)
      }
      .width('100%').height('100%')
      if (this.isUploading) { // 这里是上传中的加载进度窗口
        Column() {
          Column() {
            LoadingProgress().width(80).height(80).color(Color.Black)
            Text('正在上传短视频，请稍等……').fontSize(16)
          }
          .width('40%').padding({bottom:15})
          .backgroundColor(Color.White).justifyContent(FlexAlign.Center)
        }
        .width('100%').height('100%')
        .backgroundColor('#40000000').justifyContent(FlexAlign.Center)
      }
    }.width('100%').height('100%')
  }

  // 发布短视频
  publishVideo() {
    this.copyFile(this.videoPath) // 把相册视频复制到私有的缓存目录下
    this.isUploading = true
    // 上传短视频
    this.upload((result: number, error: string) => {
      this.isUploading = false
      if (result == 0) {
        this.promptAction.showToast({message: '成功发布您的短视频'})
        this.router.clear();
        this.router.replaceUrl({ url: 'short/ShortVideoPage' }, router.RouterMode.Single)
      } else {
        this.promptAction.showToast({message: '保存视频信息出错：'+error})
      }
    })
  }

  // 注意：
  // 1、文件目录要从UIAbilityContext获取，不能从getApplicationContext获取
  // 2、上传时要把文件路径转为'internal://cache/文件名'的形式
  //private context = this.context.getApplicationContext();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  // 保存封面图片
  saveCover() {
    let videoFileName = this.videoPath.toString().split('/').pop() as string
    let imageFileName = (videoFileName.split('.'))[0] + '_' + this.coverPos + '.jpeg'
    console.info(`image file name: ${imageFileName}`);
    this.imagePath = `${this.context.cacheDir}/${imageFileName}`
    console.info(`imagePath name: ${this.imagePath}`);
    try {
      let dstFile = fileIo.openSync(this.imagePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      // 转存为图片
      let imagePackerApi: image.ImagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 90 };
      imagePackerApi.packToFile(this.pixelMap, dstFile.fd, packOpts, (err: BusinessError) => {
        fileIo.closeSync(dstFile);
        if (err) {
          console.error(`Failed to pack the image to file.code ${err.code},message is ${err.message}`);
        } else {
          console.info('Succeeded in packing the image to file.');
        }
      })
    } catch (e) {
      console.error(`save cover failed ${e.message}`);
    }
  }

  // 把相册视频复制到私有的缓存目录下
  copyFile(path: string) {
    let fileName = path.toString().split('/').pop() as string;
    console.info(`file name: ${fileName}`);
    let dstPath = `${this.context.cacheDir}/${fileName}`
    console.info(`dstPath name: ${dstPath}`);
    let srcFile = fileIo.openSync(path.toString());
    let dstFile = fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.copyFileSync(srcFile.fd, dstFile.fd);
    fileIo.closeSync(srcFile);
    fileIo.closeSync(dstFile);
  }

  // 上传短视频
  upload(callback: (result: number, error: string) => void) {
    let imageFileName = this.imagePath.toString().split('/').pop() as string
    let imageSuffix = imageFileName.split('.').pop() as string
    let imageRealPath = 'internal://cache/' + imageFileName
    console.info('imageRealPath: ' + imageRealPath)
    // 待上传的视频封面图片
    let imageFile: request.File = { filename: imageFileName,
      name: `image`, uri: imageRealPath, type: 'image/'+imageSuffix }

    let videoFileName = this.videoPath.toString().split('/').pop() as string
    let videoSuffix = videoFileName.split('.').pop() as string
    let videoRealPath = 'internal://cache/' + videoFileName
    console.info('videoRealPath: ' + videoRealPath)
    // 待上传的视频文件
    let videoFile: request.File = { filename: videoFileName,
      name: `video`, uri: videoRealPath, type: 'video/'+videoSuffix }

    // 设定上传配置
    let config: request.UploadConfig = {
      method: 'POST', // 请求方式
      url: this.url, // 请求地址
      header: { 'Accept': '*/*' }, // 请求包头
      files: [imageFile, videoFile], // 待上传的文件列表
      data: [{ name: 'date', value: this.date}, { name: 'address', value: this.address},
        { name: 'label', value: this.label}, { name: 'desc', value: this.desc}]
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

}