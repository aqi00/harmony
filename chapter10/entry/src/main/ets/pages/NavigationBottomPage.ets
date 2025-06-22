@Entry
@Component
struct NavigationBottomPage {

  // 详见 https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-basic-components-navigation-V5#%E7%A4%BA%E4%BE%8B2
  private pageInfos: NavPathStack = new NavPathStack(); // 页面栈信息

  // 工具栏数组
  @State toolItems: Array<ToolbarItem> = [ {
      value: '首页',
      icon: $r("app.media.tab_first_normal"),
      activeIcon: $r("app.media.tab_first_pressed"),
      status: ToolbarItemStatus.ACTIVE,
      action: () => { }
    }, {
      value: '发现',
      icon: $r("app.media.tab_second_normal"),
      activeIcon: $r("app.media.tab_second_pressed"),
      status: ToolbarItemStatus.NORMAL,
      action: () => {
        this.pageInfos.pushPathByName('pageNavigationTwo', null)
      }
    }, {
      value: '我的',
      icon: $r("app.media.tab_third_normal"),
      activeIcon: $r("app.media.tab_third_pressed"),
      status: ToolbarItemStatus.NORMAL,
      action: () => {
        this.pageInfos.pushPathByName('pageNavigationThree', null)
      }
    } ]

    build() {
      // 注意下列几点：
      // 1、预览器观察不了Navigation的跳转结果，要到真机上观察
      // 2、要把pageInfos作为Navigation的构造参数，否则不响应pushPath的跳转事件
      // 3、要新建base/profile/router_map.json，并在module.json5中补充routerMap配置
      Navigation(this.pageInfos) {
        Text('这里是首页').fontSize(20).padding(20)
      }
      .title('首页') // 导航栏标题
      //.titleMode(NavigationTitleMode.Mini) // 标题模式。为Free表示标题可变化，为Full表示固定大标题，为Mini表示固定小标题
      .hideTitleBar(true) // 是否隐藏标题栏
      .hideBackButton(true) // 是否隐藏返回按钮
      .hideToolBar(false) // 是否隐藏工具栏
      .toolbarConfiguration(this.toolItems) // 设置工具栏内容
  }
}