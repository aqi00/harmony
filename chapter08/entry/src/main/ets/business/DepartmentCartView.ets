
@Component
export struct DepartmentCartView {

  build() {
    Column() {
      Text('购物车').fontSize(20).padding(10)
      Text('这里是购物车页面，参见第7章的实战项目').layoutWeight(1).fontSize(18)
    }
    .width('100%').height('100%')
  }
}
