import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  private router = this.getUIContext().getRouter();

  build() {
    Column() {
      Text('7.1 首选项')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('写入首选项').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PrefWritePage' })
          })
        Button('读取首选项').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PrefReadPage' })
          })
        Button('记住登录信息').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LoginPrefPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('写入全局变量').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GlobalWritePage' })
          })
        Button('读取全局变量').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/GlobalReadPage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('7.2 数据库')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('创建与删除数据库').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DatabaseCreatePage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('写入数据库').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DatabaseWritePage' })
          })
        Button('读取数据库').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DatabaseReadPage' })
          })
        Button('记住登录密码').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LoginDatabasePage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('7.3 文件')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('文件路径').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/FilePathPage' })
          })
        Button('写入文件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/FileWritePage' })
          })
        Button('读取文件').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/FileReadPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('文件选择器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DocumentPickerPage' })
          })
        Button('文件保存器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/DocumentSavePage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('图片选择器').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PhotoPickerPage' })
          })
        Button('保存图片至相册').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PhotoSavePage' })
          })
      }.padding({top: 3, bottom: 3})

      Text('7.4 状态存储')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('测试页面存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LocalTestPage' })
          })
        Button('写入页面存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LocalWritePage' })
          })
        Button('读取页面存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/LocalReadPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('测试应用存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/AppTestPage' })
          })
        Button('写入应用存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/AppWritePage' })
          })
        Button('读取应用存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/AppReadPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('测试持久存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PersistTestPage' })
          })
        Button('写入持久存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PersistWritePage' })
          })
        Button('读取持久存储').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/PersistReadPage' })
          })
      }.padding({top: 3, bottom: 3})
      Row() {
        Button('读取环境参数').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/EnvironmentPage' })
          })
      }.padding({top: 3, bottom: 3})


      Text('7.5 实战项目：购物车')
        .fontSize(18).margin({top:13, bottom:3})
      Row() {
        Button('购物车').fontSize(16).layoutWeight(1)
          .onClick(() => {
            this.router.pushUrl({ url: 'pages/ShoppingCartPage' })
          })
      }.padding({top: 3, bottom: 3})

    }
    .width('100%').height('100%')
  }
}