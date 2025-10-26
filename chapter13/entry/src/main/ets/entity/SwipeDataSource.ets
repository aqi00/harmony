import { VideoInfo } from './VideoInfo'

export class SwipeDataSource implements IDataSource {
  private videoList: VideoInfo[] = [];

  constructor(videoList: VideoInfo[]) {
    console.info('SwipeDataSource constructor')
    this.videoList = videoList
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