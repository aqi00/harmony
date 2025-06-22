@Entry
@Component
struct RelativePage {

  build() {
    RelativeContainer() {
      Text('我在中间').fontSize(17).id('tx_center') // 锚点组件需要分配id
        .alignRules({
          middle:{ anchor: '__container__', align: HorizontalAlign.Center},
          center:{ anchor: '__container__', align: VerticalAlign.Center}
        })
      Text('水平中间').fontSize(17)
        .alignRules({
          middle:{ anchor: '__container__', align: HorizontalAlign.Center},
          top:{ anchor: '__container__', align: VerticalAlign.Top}
        })
      Text('垂直中间').fontSize(17)
        .alignRules({
          left:{ anchor: '__container__', align: HorizontalAlign.Start},
          center:{ anchor: '__container__', align: VerticalAlign.Center}
        })
      Text('跟上级左边对齐').fontSize(17).margin({top:50})
        .alignRules({
          left:{ anchor: '__container__', align: HorizontalAlign.Start},
        })
      Text('跟上级右边对齐').fontSize(17).margin({top:50})
        .alignRules({
          right:{ anchor: '__container__', align: HorizontalAlign.End},
        })
      Text('跟上级顶部对齐').fontSize(17)
        .alignRules({
          top:{ anchor: '__container__', align: VerticalAlign.Top},
        })
      Text('跟上级底部对齐').fontSize(17)
        .alignRules({
          bottom:{ anchor: '__container__', align: VerticalAlign.Bottom},
        })
      Text('中间上面').fontSize(17).backgroundColor(Color.Orange)
        .alignRules({
          left:{ anchor: 'tx_center', align: HorizontalAlign.Start},
          bottom:{ anchor: 'tx_center', align: VerticalAlign.Top}
        })
      Text('中间下面').fontSize(17).backgroundColor(Color.Orange)
        .alignRules({
          left:{ anchor: 'tx_center', align: HorizontalAlign.Start},
          top:{ anchor: 'tx_center', align: VerticalAlign.Bottom}
        })
      Text('中间左边').fontSize(17).backgroundColor(Color.Orange)
        .alignRules({
          right:{ anchor: 'tx_center', align: HorizontalAlign.Start},
          top:{ anchor: 'tx_center', align: VerticalAlign.Top}
        })
      Text('中间右边').fontSize(17).backgroundColor(Color.Orange)
        .alignRules({
          left:{ anchor: 'tx_center', align: HorizontalAlign.End},
          top:{ anchor: 'tx_center', align: VerticalAlign.Top}
        })
    }.width('100%').height(300)
  }
}