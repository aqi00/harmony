import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct TextSearchPage {
  promptAction = this.getUIContext().getPromptAction();
  @State searchText: string = '';
  private searchController: SearchController = new SearchController()
  @State result: string = '这里显示搜索结果';

  build() {
    Column() {
      Search({ value: $$this.searchText, placeholder: '请输入关键词', controller: this.searchController })
        .width('100%')
        .placeholderColor(Color.Grey) // 提示文本颜色
        .placeholderFont({ size: 18, weight: 400 }) // 提示文本字号
        .textFont({ size: 20 }) // 文本字号
        .fontColor(Color.Black)
        .onSubmit((searchValue: string) => {
          if (searchValue === '') {
            this.promptAction.showToast({message: '请输入关键词'})
          } else {
            this.promptAction.showToast({message: '您输入的关键词为：'+searchValue})
          }
        })
      Button('开始搜索')
        .width('100%').margin(5).fontSize(18)
        .onClick(() => {
          this.result = '您输入的关键词是：'+this.searchText
          this.promptAction.showToast({message: '您输入的关键词为：'+this.searchText})
        })
      Text(this.result).width('100%').padding(5).fontSize(18)
    }
    .width('100%')
  }
}