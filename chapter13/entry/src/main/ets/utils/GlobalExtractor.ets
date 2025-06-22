import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';

// 构造单例对象
export class GlobalExtractor {
  private static instance: GlobalExtractor;
  private avMetadataExtractor?: media.AVMetadataExtractor; // 音视频元数据提取器
  private avImageGenerator?: media.AVImageGenerator; // 音视频图像生成器
  private constructor() {}

  public static getInstance(): GlobalExtractor {
    if (!GlobalExtractor.instance) {
      GlobalExtractor.instance = new GlobalExtractor();
    }
    return GlobalExtractor.instance;
  }

  // 创建提取器
  public create() {
    // 创建音视频的元数据提取器
    media.createAVMetadataExtractor()
      .then((extractor: media.AVMetadataExtractor) => {
        this.avMetadataExtractor = extractor;
        console.info('Succeeded in creating AVMetadataExtractor');
      }).catch((err: BusinessError) => {
      console.error(`Failed to create AVMetadataExtractor, error message:${err.message}`);
    })
    // 创建音视频的图像生成器
    media.createAVImageGenerator()
      .then((generator: media.AVImageGenerator) => {
        this.avImageGenerator = generator;
        console.info('Succeeded in creating AVImageGenerator');
      }).catch((err: BusinessError) => {
      console.error(`Failed to creat AVImageGenerator, error message:${err.message}`);
    })
  }

  // 释放提取器
  public release() {
    if (this.avMetadataExtractor != null) {
      this.avMetadataExtractor.release()
    }
    if (this.avImageGenerator != null) {
      this.avImageGenerator.release()
    }
  }

  // 获取视频信息
  public getVideoInfo(videoPath: string, callback: (avfd: media.AVFileDescriptor, metadata: media.AVMetadata) => void) {
    console.info('getVideoInfo: '+videoPath)
    if (this.avMetadataExtractor != null) {
      let file = fileIo.openSync(videoPath);
      let stat = fileIo.statSync(file.fd);
      let avfd: media.AVFileDescriptor = { fd: file.fd, offset: 0, length: stat.size };
      this.avMetadataExtractor.fdSrc = avfd;
      // 从fdSrc指定的音视频文件中提取元数据，回调参数的metadata为详细的元数据信息
      this.avMetadataExtractor.fetchMetadata().then((metadata: media.AVMetadata) => {
        console.info(`Succeeded in fetching Metadata, genre: ${JSON.stringify(metadata)}`);
        callback(avfd, metadata)
      }).catch((err: BusinessError) => {
        console.error(`Failed to fetch Metadata, err = ${JSON.stringify(err)}`);
      })
    }
  }

  // 获取视频缩略图
  public getThumbnail(avfd: media.AVFileDescriptor, metadata: media.AVMetadata, pos: number, callback: (pixelMap: image.PixelMap) => void) {
    if (this.avImageGenerator != null) {
      let w=300, h=300
      let videoWidth = Number(metadata.videoWidth)
      let videoHeight = Number(metadata.videoHeight)
      let videoOrientation = Number(metadata.videoOrientation)
      if (videoWidth && videoHeight && videoOrientation) {
        if ((videoOrientation+360)/90%2 == 1) {
          videoWidth = Number(metadata.videoHeight)
          videoHeight = Number(metadata.videoWidth)
        }
        let max = Math.max(videoWidth, videoHeight)
        let ratio = Math.round(max/300)
        w = videoWidth/ratio
        h = videoHeight/ratio
        console.info(`videoWidth=${videoWidth}, realHeight=${videoHeight}`)
        console.info(`max=${max}, ratio=${ratio}`)
      }
      console.info(`width=${w}, height=${h}`)
      this.avImageGenerator.fdSrc = avfd
      let timeUs = pos*1000*1000 // 缩略图所处的时间点，单位微秒
      // AV_IMAGE_QUERY_NEXT_SYNC表示取时间点之后的关键帧，AV_IMAGE_QUERY_PREVIOUS_SYNC表示取时间点之前的关键帧
      let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC
      let param: media.PixelMapParams = {
        width : w, // 缩略图的宽度
        height : h // 缩略图的高度
      }
      console.info(`timeUs=${timeUs}`)
      // 从视频文件的指定时间点获取帧图像
      this.avImageGenerator.fetchFrameByTime(timeUs, queryOption, param).then((pixelMap) => {
          callback(pixelMap)
        }).catch((err: BusinessError) => {
        console.error(`Failed to fetch FrameByTime, err = ${JSON.stringify(err)}`)
      })
    }
  }

}
