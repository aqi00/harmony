import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

let avMetadataExtractor: media.AVMetadataExtractor; // 音视频元数据提取器
let avImageGenerator: media.AVImageGenerator; // 音视频图像生成器

@Entry
@Component
struct VideoInfoPage {
  @State message: string = ''; // 视频信息
  @State videoPath: string = ''; // 视频路径
  @State pixelMap: PixelMap | undefined = undefined; // 像素图

  aboutToAppear() {
    // 创建音视频的元数据提取器
    media.createAVMetadataExtractor()
      .then((extractor: media.AVMetadataExtractor) => {
        avMetadataExtractor = extractor;
        console.info('Succeeded in creating AVMetadataExtractor');
      }).catch((err: BusinessError) => {
      console.error(`Failed to create AVMetadataExtractor, error message:${err.message}`);
    })
    // 创建音视频的图像生成器
    media.createAVImageGenerator()
      .then((generator: media.AVImageGenerator) => {
        avImageGenerator = generator;
        console.info('Succeeded in creating AVImageGenerator');
      }).catch((err: BusinessError) => {
      console.error(`Failed to creat AVImageGenerator, error message:${err.message}`);
    })
  }

  aboutToDisappear() {
    if (avMetadataExtractor != null) {
      avMetadataExtractor.release()
    }
    if (avImageGenerator != null) {
      avImageGenerator.release()
    }
  }

  // 获取视频缩略图
  getThumbnail(path: string, avfd: media.AVFileDescriptor, metadata: media.AVMetadata) {
    if (avImageGenerator != null) {
      let w=300, h=300
      let width = Number(metadata.videoWidth)
      let height = Number(metadata.videoHeight)
      let orientation = Number(metadata.videoOrientation)
      if (width && height && orientation) {
        if ((orientation+360)/90%2 == 1) {
          width = Number(metadata.videoHeight)
          height = Number(metadata.videoWidth)
        }
        let max = Math.max(width, height)
        let ratio = Math.round(max/300)
        w = width/ratio
        h = height/ratio
      }
      avImageGenerator.fdSrc = avfd
      let timeUs = 1000*1000 // 缩略图所处的时间点，单位微秒
      // AV_IMAGE_QUERY_NEXT_SYNC表示取时间点之后的关键帧，AV_IMAGE_QUERY_PREVIOUS_SYNC表示取时间点之前的关键帧
      let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC
      let param: media.PixelMapParams = {
        width : w, // 缩略图的宽度
        height : h // 缩略图的高度
      }
      // 从视频文件的指定时间点获取帧图像
      avImageGenerator.fetchFrameByTime(timeUs, queryOption, param)
        .then((pixelMap) => {
          this.pixelMap = pixelMap // Image组件绑定this.pixelMap即可显示图像
        }).catch((err: BusinessError) => {
        console.error(`Failed to fetch FrameByTime, err = ${JSON.stringify(err)}`)
      })
    }
  }

  // 获取视频信息
  getVideoInfo() {
    if (avMetadataExtractor != null) {
      // 打开视频文件获得文件对象
      let file = fileIo.openSync(this.videoPath)
      let stat = fileIo.statSync(file.fd)
      let avfd: media.AVFileDescriptor = { fd: file.fd, offset: 0, length: stat.size }
      avMetadataExtractor.fdSrc = avfd
      // 从fdSrc指定的音视频文件中提取元数据，回调参数的metadata为详细的元数据信息
      avMetadataExtractor.fetchMetadata().then((metadata: media.AVMetadata) => {
        console.info(`Succeeded in fetching Metadata, genre: ${JSON.stringify(metadata)}`);
        this.message = `视频文件路径为${this.videoPath}，` +
          `视频大小为${stat.size}字节，媒体类型为${metadata.mimeType}，` +
          `持续时间为${metadata.duration}毫秒，创建时间为${metadata.dateTime}，` +
          `视频宽度为${metadata.videoWidth}，视频高度为${metadata.videoHeight}，` +
          `视频方向为${metadata.videoOrientation}度，` +
          `声道数量为${metadata.trackCount}，音频采样率为${metadata.sampleRate}赫兹`
        this.getThumbnail(this.videoPath, avfd, metadata) // 获取视频缩略图
      }).catch((err: BusinessError) => {
        console.error(`Failed to fetch Metadata, err = ${JSON.stringify(err)}`);
      })
    }
  }

  // 选择相册视频
  chooseVideo() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      this.videoPath = photoSelectResult.photoUris[0]
      this.getVideoInfo() // 获取视频信息
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('到相册选择视频').width('100%').fontSize(18)
        .onClick(() => {
          this.chooseVideo() // 选择相册视频
        })
      Text(this.message).width('100%').padding(5).fontSize(18)
      Image(this.pixelMap).height(300).objectFit(ImageFit.Contain)
      Video({ src: this.videoPath }).width('100%').layoutWeight(1)
        .autoPlay(false).controls(true).loop(false)
    }
    .width('100%').height('100%')
  }
}