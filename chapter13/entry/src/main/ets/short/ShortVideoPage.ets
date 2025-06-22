import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { SwipeDataSource } from '../entity/SwipeDataSource';
import { VideoInfo } from '../entity/VideoInfo';
import { VideoItemView } from './VideoItemView';
import { QueryResponse } from '../entity/QueryResponse';
import { Constants } from '../constant/Constants';

@Entry
@Component
struct ShortVideoPage {
  router = this.getUIContext().getRouter();
  // 注意这里的URL地址要换成读者在自己WiFi环境下的IP和端口
  private queryUrl: string = Constants.URL_PREFIX + 'queryVideo'; // 查询视频的完整地址
  private statusArray: string[] = ['已取消下拉', '正在下拉，但未触发下拉刷新',
    '正在下拉，且已触发下拉刷新', '松手，正在刷新', '刷新完毕'];
  @State isRefreshing: boolean = false; // 是否正在刷新
  private swiperController: SwiperController = new SwiperController();
  @State dataSource: SwipeDataSource = new SwipeDataSource([]);
  @State videoList: Array<VideoInfo> = []; // 视频列表

  // 查询视频列表
  queryVideoList() {
    // 每个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 订阅HTTP响应头事件
    httpRequest.on('headersReceive', (header: Object) => {
      console.info('header: ' + JSON.stringify(header));
    });
    let options: http.HttpRequestOptions ={
      method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
      readTimeout: 12000, // 可选，默认为60000ms
      connectTimeout: 12000, // 可选，默认为60000ms
    }
    // 根据URL地址，发起HTTP网络请求，使用callback方式作为异步方法。
    httpRequest.request(this.queryUrl, options,
      (err: BusinessError, data: http.HttpResponse) => {
        this.isRefreshing = false
        if (!err) {
          let result = data.result.toString()
          console.info('result: ' + result);
          let resp = JSON.parse(result) as QueryResponse
          this.dataSource = new SwipeDataSource(resp.videoList)
          this.videoList = resp.videoList
          console.info('this.videoList.length: ' + this.videoList.length);
        } else {
          console.info('error:' + JSON.stringify(err));
        }
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript对象
        httpRequest.destroy();
      })
  }

  aboutToAppear() {
    this.queryVideoList() // 查询视频列表
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing, promptText: '刷新中……' }) {
        Swiper(this.swiperController) {
          // ForEach(this.videoList, (item: VideoInfo) => {
          //   VideoItemView({info: item}).width('100%').height('100%')
          // }, (item: VideoInfo) => JSON.stringify(item))
          if (this.videoList && this.videoList.length>0) {
            // ForEach会主动检测数据源是否发生变化，而LazyForEach不会主动检测
            LazyForEach(this.dataSource, (item: VideoInfo) => {
              VideoItemView({info: item}).width('100%').height('100%')
            })
          }
        }
        .vertical(true) // 是否垂直方向。默认false表示水平方向
        .index(0) // 默认显示第几个组件
        .indicator(false) // 是否显示指示器
        .loop(false) // 是否循环显示
        .cachedCount(0) // 不缓存
      }
      .width('100%').layoutWeight(1)
      // 下拉刷新模拟网络请求
      .onRefreshing(() => {
        // 请求获取网络短视频。请求完毕将isRefreshing置为false
        this.queryVideoList()
      })
      .onStateChange((refreshStatus: RefreshStatus) => {
        console.info('Refresh onStatueChange state is ' + refreshStatus + ', ' + this.statusArray[refreshStatus])
      })
      .alignRules({
        bottom:{ anchor: 'im_bottom', align: VerticalAlign.Top},
      })
      Image($r('app.media.short_add')).width(114).height(76).id('im_bottom')
        .alignRules({
          middle:{ anchor: '__container__', align: HorizontalAlign.Center},
          bottom:{ anchor: '__container__', align: VerticalAlign.Bottom},
        })
        .onClick(() => {
          this.router.pushUrl({ url: 'short/ShortTakePage' })
        })
    }
    .width('100%').height('100%').backgroundColor(Color.Black)
  }
}