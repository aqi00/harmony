@Entry
@Component
struct ViewSizePage {

  build() {
    Column() {
      Text('组件宽度采取默认值')
        .fontSize(25).backgroundColor('#ffff00')
      // auto表示组件尺寸自适应内部尺寸
      Text('组件宽度自适应内部文本').width('auto')
        .fontSize(25).backgroundColor('#ffff00')
      // 100%表示组件尺寸填满上级组件空间
      Text('组件宽度占满横向空间').width('100%')
        .fontSize(25).backgroundColor('#ffff00')
      // 纯数字或者带vp的数字表示组件尺寸为固定大小
      Text('组件宽度采用固定大小').width('100vp')
        .fontSize(25).backgroundColor('#ffff00')
    }
    .width('100%')
  }
}