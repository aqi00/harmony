
@Builder
export function NavigationTwoBuilder(name: string, param: Object) {
  NavigationTwoPage() // 构建NavigationTwoPage的页面布局
}

@Component
export struct NavigationTwoPage {

  build() {
    NavDestination() {
      Text('这是发现页面').fontSize(20).margin(20)
    }
    .title('发现页面') // 导航栏标题
  }
}