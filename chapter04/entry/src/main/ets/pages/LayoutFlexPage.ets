@Entry
@Component
struct FlexPage {

  build() {
    Column() {
      Column({ space: 10 }) {
        Text('在行上（水平方向）顺序排列').fontSize(20).width('95%')
        Flex({ direction: FlexDirection.Row }) { // 子组件在容器主轴上行布局
          Text('一').width('20%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.Orange)
          Text('二').width('20%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
          Text('三').width('20%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.Orange)
          Text('四').width('20%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
        }
        .height(70).width('95%').padding(10).backgroundColor(Color.Green)

        Text('在行（水平方向）倒序排列').fontSize(20).width('95%')
        Flex({ direction: FlexDirection.RowReverse }) { // 子组件在容器主轴上反向行布局
          Text('一').width('20%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.Orange)
          Text('二').width('20%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
          Text('三').width('20%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.Orange)
          Text('四').width('20%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
        }
        .height(70).width('95%').padding(10).backgroundColor(Color.Green)

        Text('可换行，换行时顺序开头').fontSize(20).width('95%')
        Flex({ wrap: FlexWrap.Wrap }) { // 子组件多行布局
          Text('一').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.Orange)
          Text('二').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
          Text('三').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
        }
        .width('95%').padding(10).backgroundColor(Color.Green)

        Text('不可换行').fontSize(20).width('95%')
        Flex({ wrap: FlexWrap.NoWrap }) { // 子组件单行布局
          Text('一').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.Orange)
          Text('二').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
          Text('三').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.Orange)
        }
        .width('95%').padding(10).backgroundColor(Color.Green)

        Text('可换行，换行时倒序开头').fontSize(20).width('95%')
        Flex({ wrap: FlexWrap.WrapReverse , direction:FlexDirection.Row }) { // 子组件反向多行布局
          Text('一').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.Orange)
          Text('二').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
          Text('三').width('50%').height(50).textAlign(TextAlign.Center)
            .fontSize(25).backgroundColor(Color.White)
        }
        .width('95%').height(120).padding(10).backgroundColor(Color.Green)
      }.width('100%').margin({ top: 15 })
    }.width('100%')
  }
}