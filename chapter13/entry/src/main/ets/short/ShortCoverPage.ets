import { router } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { GlobalExtractor } from '../utils/GlobalExtractor';

// 缩略图信息
interface FrameThumbnail {
  seq: number
  pos: number
  pixelMap: image.PixelMap
  selected: boolean
}

@Entry
@Component
struct ShortCoverPage {
  router = this.getUIContext().getRouter();
  @State videoPath: string = ''; // 视频路径
  private coverPos = 0; // 封面位置
  private coverSeq = 0; // 封面序号
  private lastUrl: string = ''; // 上个页面的地址
  @State pixelMap: PixelMap | undefined = undefined; // 像素图
  private frameCount = 0; // 封面帧的数量
  private extractCount = 0; // 解析帧的数量
  @State frameArray: FrameThumbnail[] = []; // 缩略图列表
  private tempArray: FrameThumbnail[] = []; // 临时图列表
  private scroller: Scroller = new Scroller(); // 滚动器

  private extractor: GlobalExtractor = GlobalExtractor.getInstance();
  aboutToAppear() {
    this.extractor.create() // 创建提取器
  }

  aboutToDisappear() {
    this.extractor.release() // 释放提取器
  }

  // 添加缩略图
  addThumbnail(seq: number, pos: number, pixelMap: image.PixelMap) {
    console.info(`seq=${seq}, pos=${pos}`)
    let frame: FrameThumbnail = {seq: seq, pos: pos, pixelMap: pixelMap, selected: pos==this.coverPos}
    this.tempArray.push(frame)
    this.extractCount++
    if (this.extractCount == this.frameCount) {
      this.tempArray.sort((a, b) => a.seq-b.seq)
      this.frameArray.length = 0
      this.frameArray = this.tempArray.slice()
      setTimeout(() => {
        this.scroller.scrollToIndex(this.coverSeq, true, ScrollAlign.END)
      }, 500)
    }
  }

  onPageShow() {
    let params = this.router.getParams() as Record<string, Object>;
    this.coverPos = params?.['pos'] as number
    this.coverSeq = params?.['seq'] as number
    this.videoPath = params?.['path'] as string
    this.lastUrl = params?.['lastUrl'] as string
    console.info('coverPos='+this.coverPos+', coverSeq='+this.coverSeq)
    if (this.videoPath) {
      setTimeout(() => {
        // 获取视频信息
        this.extractor.getVideoInfo(this.videoPath, (fd, metadata) => {
          let secondCount = Math.round(Number(metadata.duration)/1000)
          this.frameCount = secondCount>16 ? 15 : secondCount
          for (let seq=0; seq<this.frameCount; seq++) {
            let pos = seq
            if (pos!=0 && secondCount>16) {
              pos = secondCount/this.frameCount*seq
            }
            // 获取视频缩略图
            this.extractor.getThumbnail(fd, metadata, pos, (pixelMap) => {
              this.addThumbnail(seq, pos, pixelMap) // 添加缩略图
            })
          }
        })
      }, 100)
    }
  }

  // 刷新图片列表
  refreshImageList(item: FrameThumbnail) {
    console.info('item.pos='+item.pos)
    this.coverPos = item.pos
    this.coverSeq = item.seq
    this.tempArray.length = 0
    this.tempArray = this.frameArray.slice()
    for (let i=0; i<this.tempArray.length; i++) {
      if (this.tempArray[i].pos == this.coverPos) {
        this.tempArray[i].selected = true
      } else {
        this.tempArray[i].selected = false
      }
    }
    this.frameArray.length = 0
    this.frameArray = this.tempArray.slice()
  }

  build() {
    Column() {
      Video({ src: this.videoPath }).width('100%').layoutWeight(1)
        .objectFit(ImageFit.Contain) // 组件区域包含整个视频画面
        .autoPlay(true) // 是否自动轮播
        .controls(true) // 是否显示控制条
        .loop(true) // 是否循环轮播
      List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
        ForEach(this.frameArray, (item: FrameThumbnail) => {
          ListItem() {
            Stack() {
              Image(item.pixelMap).width('100%').height('100%')
                .objectFit(ImageFit.Contain)
              Shape() {
                Rect().width('100%').height('100%')
                  .strokeWidth(8).stroke('#ff0000').fill('#00ffff00')
              }.visibility(item.selected ? Visibility.Visible : Visibility.None)
            }
            .width(54).height('100%')
            .onClick(() => {
              this.refreshImageList(item) // 刷新图片列表
            })
          }
        })
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .width('100%').height(100).padding({ left:6, right:6 })
      Row() {
        Button('取消').width('100%').layoutWeight(1).margin({ right:6 })
          .type(ButtonType.Normal).fontSize(17)
          .fontColor(Color.White).backgroundColor(Color.Gray)
          .onClick(() => {
            this.router.back() // 返回到前一个页面
          })
        Button('保存').width('100%').layoutWeight(1)
          .type(ButtonType.Normal).fontSize(17)
          .fontColor(Color.White).backgroundColor($r('app.color.rose'))
          .onClick(() => {
            this.router.back({ // 返回到前一个页面
              url: this.lastUrl,
              params: {
                pos: this.coverPos
              }
            })
          })
      }.width('100%').padding({ left:6, right:6 })
    }
    .width('100%').height('100%')
  }
}