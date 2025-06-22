@Entry
@Component
struct ImageViewPage {
  @State res: Resource = $r('app.media.apple'); // 图片资源
  @State fitMode: ImageFit = ImageFit.Cover; // 填充模式

  build() {
    Column() {
      Row() {
        Button('双轴覆盖').fontSize(16).layoutWeight(1)
          .onClick(() => {
            // 横纵两个方向轴都填满，也就是两个方向轴都不留空白。
            // 保持图像的宽高比，图像很可能会被裁剪。
            this.fitMode = ImageFit.Cover
          })
        Button('单轴覆盖').fontSize(16).layoutWeight(1)
          .onClick(() => {
            // 横纵两方向轴只填满一个，很可能在某个方向轴留出空白。
            // 保持图像的宽高比，图像不会被裁剪。
            // 如果Image组件放得下图像，就显示完整图像（此时图像不缩放）。如果Image组件放不下图像，就缩小图像以便能够塞进去
            this.fitMode = ImageFit.Contain
          })
        Button('填满四周').fontSize(16).layoutWeight(1)
          .onClick(() => {
            // 横纵两个方向轴都填满，且确保图像没有缺失。
            // 不保持图像的宽高比，此时图像往往会拉伸变形。
            this.fitMode = ImageFit.Fill
          })
        Button('不放大').fontSize(16).layoutWeight(1)
          .onClick(() => {
            // 如果图像越界，就缩小图像；如果图像没越界，就保持原大小
            // 保持图像的宽高比，图像不会被裁剪。图片缩小或者保持不变。
            this.fitMode = ImageFit.ScaleDown
          })
      }
      Image(this.res).width('100%').height(200)
        .objectFit(this.fitMode) // 设置图片的填充效果
      Row() {
        Button('显示jpg').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.res = $r('app.media.bliss')
          })
        Button('显示png').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.res = $r('app.media.apple')
          })
      }
    }
    .width('100%')
  }
}