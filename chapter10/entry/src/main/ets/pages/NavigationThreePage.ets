
@Builder
export function NavigationThreeBuilder(name: string, param: Object) {
  NavigationThreePage() // 构建NavigationThreePage的页面布局
}

@Component
export struct NavigationThreePage {

  build() {
    NavDestination() {
      Text('这是我的页面').fontSize(20).margin(20)
    }
    .title('我的页面') // 导航栏标题
  }
}