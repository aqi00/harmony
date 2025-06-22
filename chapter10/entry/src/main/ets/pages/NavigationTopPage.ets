import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct NavigationTopPage {
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State message: string = '这里是页面内容'; // 操作结果

  // 菜单项数组
  @State menuItems: Array<NavigationMenuItem> = [
    {
      value: '1',
      icon: 'resources/base/media/ic_refresh.png',
      action: () => {
        this.message = '您点击了刷新按钮'
      }
    },
    {
      value: '2',
      icon: 'resources/base/media/ic_about.png',
      action: () => {
        this.message = '这是个演示demo'
      }
    },
    {
      value: '3',
      icon: 'resources/base/media/ic_quit.png',
      action: () => {
        this.router.back() // 返回到前一个页面
      }
    }
  ];

  // 构建菜单栏布局
  @Builder navigationMenus() {
    Row() {
      Image($r('app.media.ic_refresh')).width(30).height(30).margin(5)
        .onClick(() => {
          this.message = '您点击了刷新按钮'
          this.promptAction.showToast({ message: '您点击了刷新按钮' })
        })
      Image($r('app.media.ic_about')).width(30).height(30).margin(5)
        .onClick(() => {
          this.message = '这是个演示demo'
          this.promptAction.showToast({ message: '这是个演示demo' })
        })
      Image($r('app.media.ic_quit')).width(30).height(30).margin(5)
        .onClick(() => {
          this.router.back() // 返回到前一个页面
        })
    }.padding(15)
  }

  build() {
    Navigation() {
      Text(this.message).fontSize(20).padding(20)
    }
    .title('主标题') // 导航栏标题
    .titleMode(NavigationTitleMode.Mini) // 标题模式。为Free表示标题可变化，为Full表示固定大标题，为Mini表示固定小标题
    .hideTitleBar(false) // 是否隐藏标题栏
    .hideBackButton(false) // 是否隐藏返回按钮
    .mode(NavigationMode.Stack) // 导航栏显示模式。为Stack表示导航栏和内容区域层叠显示，为Split表示导航栏和内容区域并排显示，为Auto表示基于组件宽度自适应单栏和双栏
    //.menus(this.menuItems) // 标题栏右侧的菜单列表
    .menus(this.navigationMenus()) // 标题栏右侧的菜单列表
    .hideToolBar(true) // 是否隐藏工具栏
  }
}