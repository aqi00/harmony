@Entry
@Component
struct PullUpLoadingPage {
  @State hint: string = '请拉到列表底部后继续上拉';
  @State message: string = '继续上拉加载更多内容'; // 上拉加载结果
  private arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];

  build() {
    Column() {
      Text(this.hint).fontSize(18)
      List({ space: 12, initialIndex: 0 }) {
        ForEach(this.arr, (item: number) => {
          ListItem() {
            Text(`第${item}项`).height(50).fontSize(18)
          }.padding({ left: 12, right: 12 })
        })
        ListItem() { // 列表的最后一项
          Text(this.message).height(80).fontSize(18)
        }.padding({ left: 12, right: 12 }).margin({bottom: 50})
      }
      //.width('100%').layoutWeight(1).listDirection(Axis.Vertical)
      // 在到达容器末尾时触发onReachEnd回调。List/Grid/WaterFlow均可触发onReachEnd
      .onReachEnd(() => {
        // 加载更多数据逻辑
        setTimeout(() => {
          this.message = '加载完毕'
          console.info('上拉加载结束')
        }, 2000)
        this.message = '正在加载……'
        console.info('正在上拉加载')
      })
    }
    .width('100%').height('100%')
  }
}