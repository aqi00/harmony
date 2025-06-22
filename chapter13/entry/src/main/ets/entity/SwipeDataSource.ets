import { VideoInfo } from './VideoInfo'

export class SwipeDataSource implements IDataSource {
  private videoList: VideoInfo[] = []
  private url: string[] = ['https://ptgl.fujian.gov.cn:8088/masvod/public/2018/04/17/20180417_162d3639356_r38_1200k.mp4',
    'https://ptgl.fujian.gov.cn:8088/masvod/public/2019/04/15/20190415_16a1ef11c24_r38_1200k.mp4',
    'https://ptgl.fujian.gov.cn:8088/masvod/public/2020/09/26/20200926_174c8f9e4b6_r38_1200k.mp4',
    'https://ptgl.fujian.gov.cn:8088/masvod/public/2021/03/19/20210319_178498bcae9_r38.mp4',
    'https://www.fujian.gov.cn/masvod/public/2022/07/15/20220715_18201603713_r38_1200k.mp4',
    'https://www.fujian.gov.cn/masvod/public/2023/04/25/20230425_187b71018de_r38_1200k.mp4',
    'https://video.zohi.tv/fs/transcode/20240520/8cc/355193-1716184798-transv.mp4']

  constructor(videoList: VideoInfo[]) {
    console.info('SwipeDataSource constructor')
    this.videoList = videoList
    // if (videoList==undefined || videoList.length==0) {
    //   for (let i=0; i<this.url.length; i++) {
    //     let videoInfo: VideoInfo = { date:`第${i+1}届数字中国峰会迎宾曲`, video:this.url[i] }
    //     this.videoList.push(videoInfo)
    //   }
    // }
  }

  totalCount(): number {
    return this.videoList.length
  }

  getData(index: number): VideoInfo {
    return this.videoList[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}