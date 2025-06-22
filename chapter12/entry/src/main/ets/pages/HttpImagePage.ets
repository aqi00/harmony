import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';

// 加载事件信息
interface LoadEvent {
  width: number;
  height: number;
  componentWidth: number;
  componentHeight: number;
  loadingStatus: number;
  contentWidth: number;
  contentHeight: number;
  contentOffsetX: number;
  contentOffsetY: number;
}

@Entry
@Component
struct HttpImagePage {
  @State imagePath: string | Resource = ''; // 图片路径
  @State load_result: string = ''; // 图片加载结果
  private load_default = $r('app.media.load_default'); // 占位图片
  private load_error = $r('app.media.load_error'); // 出错图片
  private count = 0; // 计数值，用来控制显示有效链接还是无效链接
  private validUrl = 'https://i-blog.csdnimg.cn/blog_migrate/8c908eb273524a873132035df0b36df0.jpeg';
  private invalidUrl = 'https://qq.com/aaa.jpeg';

  @State pixelMap: PixelMap | undefined = undefined; // 像素图
  private webImageUrl = 'https://i-blog.csdnimg.cn/blog_migrate/fcf98ea6e6596c53f67d4b899b80356f.jpeg';
  private aiController: ImageAnalyzerController = new ImageAnalyzerController();
  private options: ImageAIOptions = {
    // 支持主体识别和文本识别
    types: [ImageAnalyzerType.SUBJECT, ImageAnalyzerType.TEXT],
    aiController: this.aiController // 人工智能控制器
  };

  build() {
    Column() {
      Button('直接加载网络图片').width('100%').fontSize(18)
        .onClick(() => {
          this.count++
          setTimeout(() => {
            this.imagePath = this.count%2==1 ? this.validUrl : this.invalidUrl
          }, 1200)
        })
      Image(this.imagePath).width('100%').height(300).objectFit(ImageFit.Contain)
        .alt(this.load_default) // 加载结束之前的占位图
        .onComplete((event?: LoadEvent) => {
          if (event) {
            console.info(`onComplete loadingStatus:${event.loadingStatus}, width:${event.width}, height:${event.height}`)
            if (this.count%2==1) {
              this.load_result = '图片加载成功'
            }
          }
        })
        .onError( (error: ImageError) => {
          console.error(`onError ${error.message}`)
          if (this.imagePath != '') {
            this.imagePath = this.load_error
            this.load_result = '图片加载错误：' + error.message
          }
        })
      Text(this.load_result).width('100%').fontSize(18).padding(5)
      Button('HTTP加载网络图片').width('100%').fontSize(18).margin({top:10})
        .onClick(() => {
          this.requestImageUrl(this.webImageUrl) // 请求加载网络图片
        })
      Image(this.pixelMap, this.options)
        .enableAnalyzer(true) // 是否支持AI分析，当前支持主体识别、文字识别和对象查找等功能
        .width('100%').height(400).objectFit(ImageFit.Contain)
        .alt(this.load_default) // 加载完之前的占位图
    }
    .width('100%')
  }

  // 请求加载网络图片
  requestImageUrl(url: string) {
    // 每个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    httpRequest.request(url, (error: BusinessError, data: http.HttpResponse)=> {
      if (error) {
        console.error(`request image failed: url: ${url}, code: ${error.code}, message: ${error.message}`);
      } else {
        let imgData: ArrayBuffer = data.result as ArrayBuffer;
        console.info(`request image success, size: ${imgData.byteLength}`);
        let imgSource: image.ImageSource = image.createImageSource(imgData);
        imgSource.createPixelMap().then((pixelMap: PixelMap) => {
          console.info('image createPixelMap success');
          this.pixelMap = pixelMap;
        })
      }
    })
  }
}