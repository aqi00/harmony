import { font } from '@kit.ArkUI';

@Entry
@Component
struct TextFontPage {
  @State family: string = 'HarmonyOS Sans';
  private font = this.getUIContext().getFont();

  aboutToAppear() {
    // 注意字体文件的大小写。预览器中不区分文件大小写，真机会区分文件大小写
    this.font.registerFont({
      familyName: 'KaiTi',
      familySrc: '/fonts/simkai.ttf' // fonts文件夹与pages目录同级
    })
    this.font.registerFont({
      familyName: 'LiShu',
      familySrc: '/fonts/SIMLI.TTF' // fonts文件夹与pages目录同级
    })
    this.font.registerFont({
      familyName: 'ShuTi',
      familySrc: '/fonts/FZSTK.TTF' // fonts文件夹与pages目录同级
    })
  }

  build() {
    Column() {
      // fontStyle定义了两种字体风格：普通、斜体
      Text('默认字体').fontSize(30)
        .fontStyle(FontStyle.Normal)
      Text('斜体文字').fontSize(30)
        .fontStyle(FontStyle.Italic)
      // fontWeight取值范围[100, 900]，默认400，每级递增100
      Text('100大小的文字').fontSize(30).fontWeight(100)
      Text('200大小的文字').fontSize(30).fontWeight(200)
      Text('300大小的文字').fontSize(30).fontWeight(300)
      Text('400大小的文字').fontSize(30).fontWeight(400)
      Text('500大小的文字').fontSize(30).fontWeight(500)
      Text('600大小的文字').fontSize(30).fontWeight(600)
      Text('700大小的文字').fontSize(30).fontWeight(700)
      Text('800大小的文字').fontSize(30).fontWeight(800)
      Text('900大小的文字').fontSize(30).fontWeight(900)
      Text('Lighter文字').fontSize(30)
        .fontWeight(FontWeight.Lighter) // Lighter相当于fontWeight=100
      Text('Normal文字').fontSize(30)
        .fontWeight(FontWeight.Normal) // Normal相当于fontWeight=400
      Text('Regular文字').fontSize(30)
        .fontWeight(FontWeight.Regular) // Regular相当于fontWeight=400
      Text('Medium文字').fontSize(30)
        .fontWeight(FontWeight.Medium) // Medium相当于fontWeight=500
      Text('Bold文字').fontSize(30)
        .fontWeight(FontWeight.Bold) // Bold相当于fontWeight=700
      Text('Bolder文字').fontSize(30)
        .fontWeight(FontWeight.Bolder) // Bolder相当于fontWeight=900
      // Text('鸿蒙文字').fontSize(30)
      //   .fontFamily('HarmonyOS Sans') // 鸿蒙默认字体为HarmonyOS Sans
      Row() {
        Button('楷体文字').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.family = 'KaiTi'
          })
        Button('隶书文字').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.family = 'LiShu'
          })
        Button('方正舒体').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.family = 'ShuTi'
          })
      }.padding({top: 6, bottom: 6})
      Text('白日依山尽，黄河入海流').fontSize(30).fontFamily(this.family)
    }
    .width('100%')
  }
}