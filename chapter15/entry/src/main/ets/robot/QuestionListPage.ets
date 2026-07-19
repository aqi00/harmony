import { common } from '@kit.AbilityKit';

import { GlobalThis } from '../utils/GlobalThis';
import { QuestionInfo } from '../entity/QuestionInfo';
import { QuestionDB } from '../entity/QuestionDB';

@Entry
@Component
struct QuestionListPage {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();

  //private questionDao: QuestionDB = new QuestionDB()
  private questionDao: QuestionDB = GlobalThis.getInstance().getQuestionDB()
  @State questionList: QuestionInfo[] = []

  loadAllQuestion() {
    setTimeout(() => {
      this.questionList = this.questionDao.queryAllCustomQuestion(); // 加载所有问答信息
      console.info(`questionList.size=${this.questionList.length}`)
    }, 100)
  }

  onPageShow(): void {
    this.loadAllQuestion()
  }

  popupDeleteDialog(item: QuestionInfo) {
    this.promptAction.showDialog({
      title: '请确认',
      message: '你是否要删除该问题：'+item.question,
      buttons: [
        { text: '是', color: '#000000' },
        { text: '否', color: '#000000' },
      ]
    }, (err, data) => {
      if (err) {
        console.info('showDialog err: ' + err);
        return;
      }
      if (data.index == 0) {
        this.questionDao.delete(item.question)
        this.loadAllQuestion()
      }
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_back')).width('35').height('35')
          .onClick(() => {
            this.router.back() // 关闭当前页面
          })
        Text('问答列表').layoutWeight(1).fontSize(20).textAlign(TextAlign.Center)
        Text('添加新问答').fontSize(17)
          .onClick(() => {
            this.router.pushUrl({
              url: 'robot/QuestionEditPage',
              params: { id: -1 }
            })
          })
      }
      .width('100%').height(60).padding(10)
      Divider().width('100%').color(Color.Gray).padding({left:10, right:10})

      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.questionList, (item: QuestionInfo) => {
          ListItem() {
            Row() {
              Text(item.question).height(50).fontSize(18)
            }
            .width('100%')
            .onClick(() => {
              this.router.pushUrl({
                url: 'robot/QuestionEditPage',
                params: { id: item.id }
              })
            })
            .gesture(
              // fingers为触发长按的最少手指数。默认为1指
              // repeat表示是否连续触发事件回调。默认false
              LongPressGesture({ fingers: 1, repeat: false })
                .onAction((event: GestureEvent) => {
                  if (event) {
                    this.popupDeleteDialog(item)
                  }
                })
            )
          }
        })
      }
      .listDirection(Axis.Vertical) // 列表排列方向。默认Vertical表示垂直，为Horizontal表示水平
      .scrollBar(BarState.Off) // 滚动条状态。默认BarState.Auto
      .divider({ strokeWidth: 0.5, color: Color.Gray, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
      .edgeEffect(EdgeEffect.Fade) // 边缘效果。默认Spring表示边缘拉动呈回弹效果，为Fade表示拉动不回弹但有圆弧阴影
      .width('100%').padding(10)
    }
    .height('100%')
    .width('100%')
  }
}