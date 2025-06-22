@Entry
@Component
struct PullDownRefreshPage {
  private statusArray: string[] = ['已取消下拉', '正在下拉，但未触发下拉刷新',
    '正在下拉，且已触发下拉刷新', '松手，正在刷新', '刷新完毕'];
  @State message: string = '请在屏幕上下拉'; // 下拉刷新结果
  @State isRefreshing: boolean = false; // 是否正在刷新

  build() {
    Refresh({ refreshing: $$this.isRefreshing, promptText: '刷新中……' }) {
      Text(this.message).fontSize(18)
    }
    .width('100%').height('100%')
    .refreshOffset(30) // 触发刷新的下拉偏移量。未设置promptText时默认为64，设置了promptText后默认为96
    // 下拉刷新模拟网络请求，延迟2秒后结束刷新操作
    .onRefreshing(() => {
      setTimeout(() => {
        this.isRefreshing = false
      }, 2000)
      this.message = '正在刷新……'
    })
    .onStateChange((refreshStatus: RefreshStatus) => {
      console.info('Refresh onStatueChange state is ' + refreshStatus + ', ' + this.statusArray[refreshStatus])
      if (refreshStatus == RefreshStatus.Done) {
        this.message = '刷新结束'
      }
    })
  }
}