import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { fileIo } from '@kit.CoreFileKit';

let avMetadataExtractor: media.AVMetadataExtractor; // 音视频元数据提取器

@Entry
@Component
struct AudioChoosePage {
  context = this.getUIContext().getHostContext() as common.Context;
  @State message: string = ''; // 音频信息
  @State audioPath: string = ''; // 音频路径

  aboutToAppear() {
    // 创建音视频的元数据提取器
    media.createAVMetadataExtractor()
      .then((extractor: media.AVMetadataExtractor) => {
        avMetadataExtractor = extractor;
        console.info('Succeeded in creating AVMetadataExtractor');
      }).catch((err: BusinessError) => {
      console.error(`Failed to create AVMetadataExtractor, error message:${err.message}`);
    })
  }

  aboutToDisappear() {
    if (avMetadataExtractor != null) {
      avMetadataExtractor.release()
    }
  }

  // 获取音频信息
  getAudioInfo() {
    if (avMetadataExtractor != null) {
      // 打开音频文件获得文件对象
      let file = fileIo.openSync(this.audioPath)
      let stat = fileIo.statSync(file.fd)
      let avfd: media.AVFileDescriptor = { fd: file.fd, offset: 0, length: stat.size }
      avMetadataExtractor.fdSrc = avfd
      // 从fdSrc指定的音视频文件中提取元数据，回调参数的metadata为详细的元数据信息
      avMetadataExtractor.fetchMetadata().then((metadata: media.AVMetadata) => {
        console.info(`Succeeded in fetching Metadata, genre: ${JSON.stringify(metadata)}`);
        this.message = `音频文件路径为${this.audioPath}，` +
          `音频大小为${stat.size}字节，媒体类型为${metadata.mimeType}，` +
          `持续时间为${metadata.duration}毫秒，创建时间为${metadata.dateTime}，` +
          `声道数量为${metadata.trackCount}，音频采样率为${metadata.sampleRate}赫兹`
      }).catch((err: BusinessError) => {
        console.error(`Failed to fetch Metadata, err = ${JSON.stringify(err)}`);
        this.message = '获取元数据失败，请检查该文件是否为音视频格式'
      })
    }
  }

  // 选择音频文件
  chooseAudio() {
    let documentSelectOptions = new picker.DocumentSelectOptions()
    documentSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    documentSelectOptions.fileSuffixFilters = ['mp3', 'aac', 'ogg', 'amr', 'm4a', 'wav']
    let documentPicker = new picker.DocumentViewPicker(this.context)
    documentPicker.select(documentSelectOptions)
      .then((documentSelectResult: Array<string>) => {
        console.info('documentPicker.select successfully, documentSelectResult uri: ' + JSON.stringify(documentSelectResult));
        this.audioPath = documentSelectResult[0] // 音频路径
        this.getAudioInfo() // 获取音频信息
      }).catch((err: BusinessError) => {
      console.error('documentPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('选择一个音频').width('100%').fontSize(18)
        .onClick(() => {
          this.chooseAudio() // 选择音频文件
        })
      Text(this.message).width('100%').padding(5).fontSize(18)
    }
    .width('100%').height('100%')
  }
}