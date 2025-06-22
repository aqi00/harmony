import { Utils } from '../utils/Utils'
import { common } from '@kit.AbilityKit';
import { request, BusinessError } from '@kit.BasicServicesKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';

@Entry
@Component
struct HttpDownloadPage {
  context = this.getUIContext().getHostContext();
  private URL_IMAGE = 'https://i-blog.csdnimg.cn/blog_migrate/fcf98ea6e6596c53f67d4b899b80356f.jpeg';
  private URL_VIDEO = 'https://ptgl.fujian.gov.cn:8088/masvod/public/2021/03/19/20210319_178498bcae9_r38.mp4';
  private blank = $r('app.media.blank'); // 空白图片
  @State result: string = ''; // 文件下载结果
  @State imagePath: string | Resource = ''; // 图片路径

  // 下载网络图片
  downloadImage() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext
    //let update_time = Utils.getNowDatetime()
    let fileName = Utils.getNowDatetime() + '.jpg'
    let filePath = context.filesDir + '/' + fileName
    console.info('write filePath: ' + filePath);
    // 设定下载配置
    let config: request.DownloadConfig = {
      url: this.URL_IMAGE, // 请求地址
      header: { // 请求包头
        'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN',
      },
      // 允许连上WIFI或者蜂窝网络时下载
      networkType: request.NETWORK_WIFI | request.NETWORK_MOBILE,
      filePath: filePath }
    let downloadTask: request.DownloadTask; // 下载任务
    // 请求下载网络文件
    request.downloadFile(this.context, config).then(data => {
      downloadTask = data;
      // 订阅下载进度事件
      downloadTask.on('progress', (size, tot) => {
        let ratio = Math.round(100.0*size/tot)
        this.result += `下载进度：${ratio}%\n`
      })
      // 订阅下载完成事件
      downloadTask.on('complete', () => {
        this.result += '下载完成\n'
        // 文件有三种路径：
        // 1、文件的真实路径，只能用于fs读写和下载，既不能用于Image组件，也不能用于上传；
        // 2、通过fileUri.getUriFromPath转换后的file://路径，可用于Image组件；
        // 3、以internal://开头的路径，可用于上传
        this.imagePath = fileUri.getUriFromPath(filePath)
        console.info('imagePath: ' + this.imagePath);
      })
    }).catch((err: BusinessError) => {
      console.error('Failed to request the download. Cause: ' + JSON.stringify(err));
    })
  }

  // 下载网络视频
  downloadVideo() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext
    // let update_time = Utils.getNowDatetime()
    // let filePath = context.filesDir + '/' + update_time + '.mp4';
    let filePath = context.filesDir + '/download.mp4'
    console.info('write filePath: ' + filePath)
    if (fileIo.accessSync(filePath)) {
      fileIo.unlinkSync(filePath)
    }
    // 设定下载配置
    let config: request.DownloadConfig = {
      url: this.URL_VIDEO, // 请求地址
      header: { // 请求包头
        'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN',
      },
      networkType: request.NETWORK_WIFI | request.NETWORK_MOBILE, // 允许连上WiFi或者蜂窝网络时下载
      filePath: filePath }
    let downloadTask: request.DownloadTask; // 下载任务
    // 请求下载网络文件
    request.downloadFile(this.context, config).then(data => {
      downloadTask = data;
      // 订阅下载进度事件
      downloadTask.on('progress', (size, tot) => {
        let ratio = Math.round(100.0*size/tot)
        this.result += `下载进度：${ratio}%\n`
      })
      // 订阅下载完成事件
      downloadTask.on('complete', () => {
        this.result += '下载完成\n视频文件路径为：'+filePath
      })
    }).catch((err: BusinessError) => {
      console.error('Failed to request the download. Cause: ' + JSON.stringify(err));
    })
  }

  build() {
    Column() {
      Button('下载视频').width('100%').fontSize(18)
        .onClick(() => {
          this.result = ''
          this.downloadVideo() // 下载网络视频
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
      Button('下载图片').width('100%').fontSize(18)
        .onClick(() => {
          this.result = ''
          this.imagePath = this.blank
          this.downloadImage() // 下载网络图片
        })
      Image(this.imagePath).width('100%').height(300).objectFit(ImageFit.Contain)
    }
    .width('100%')
  }
}