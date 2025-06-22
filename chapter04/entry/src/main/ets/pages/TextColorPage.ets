@Entry
@Component
struct TextColorPage {

  build() {
    Column() {
      // 使用SDK自带的Color枚举颜色
      Text('设置枚举颜色的红色').fontSize(25).fontColor(Color.Red)
      // 使用0x打头的十六进制的RGB色值
      Text('设置十六进制文字颜色').fontSize(25).fontColor(0x0000ff)
      // 使用#开头的RGB色值字符串
      Text('设置六位文字颜色').fontSize(25).fontColor('#000000')
      // 需要在color.json中配置颜色
      Text('引用资源文件的颜色').fontSize(25).fontColor($r('app.color.green'))
      Text('设置八位文字颜色').fontSize(25).fontColor('#FF000000')
      Text('背景设置为绿色').fontSize(25).backgroundColor('#00FF00')
    }.width('100%')
  }
}