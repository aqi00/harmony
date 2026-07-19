import { util } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

import { GlobalThis } from '../utils/GlobalThis';
import { QuestionInfo } from '../entity/QuestionInfo';
import { QuestionDB } from '../entity/QuestionDB';

@Entry
@Component
struct QuestionEditPage {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  router = this.getUIContext().getRouter();
  promptAction = this.getUIContext().getPromptAction();
  @State title: string = '';
  @State option: string = '';
  @State question: string = '';
  @State answer: string = '';
  private questionId: number = -1;
  @State isEditing: boolean = false;
  //private questionDao: QuestionDB = new QuestionDB()
  private questionDao: QuestionDB = GlobalThis.getInstance().getQuestionDB()
  private questionInfo: QuestionInfo | undefined // 问答信息

  aboutToAppear() {
    // 获取上个页面传来的参数
    let params = this.router.getParams() as Record<string, Object>;
    this.questionId = params?.['id'] as number
    console.info('questionId='+this.questionId)

    if (this.questionId == -1) { // 添加新问答
      this.title = '添加问答';
      this.option = '保存';
      this.isEditing = true
    } else { // 查看问答详情
      this.title = '问答详情';
      this.option = '编辑';
      this.showQuestion(); // 显示问答详情
    }
  }

  showQuestion() {
    // 根据编号加载问答信息
    this.questionInfo = this.questionDao.queryQuestionById(this.questionId);
    this.question = this.questionInfo!.question
    this.answer = this.questionInfo!.answer
    this.isEditing = false
  }

  saveQuestion() {
    if (this.question === '') {
      this.promptAction.showToast({message: '请先输入问题描述'});
      return;
    }
    if (this.answer === '') {
      this.promptAction.showToast({message: '请先输入回答内容'});
      return;
    }
    if (this.questionId == -1) { // 添加来源
      this.questionInfo = new QuestionInfo(this.question, this.answer, 1);
      this.questionDao.insert(this.questionInfo); // 插入一条问答信息
    } else { // 查看来源
      this.questionInfo!.question = this.question;
      this.questionInfo!.answer = this.answer;
      this.questionDao.update(this.questionInfo!); // 更新问答信息
      let voicePath = util.format('%s/robot/%d.mp3', this.context.filesDir, this.questionInfo!.id);
      if (fileIo.accessSync(voicePath)) {
        // 如果已经存在该问答的语音文件，就要删除原文件，这样下次才会重新合成新的语音文件
        fileIo.unlinkSync(voicePath)
      }
    }
    this.promptAction.showToast({message: '成功保存问答信息'});
    this.router.back() // 关闭当前页面
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_back')).width('35').height('35')
          .onClick(() => {
            this.router.back() // 关闭当前页面
          })
        Text(this.title).layoutWeight(1).fontSize(20).textAlign(TextAlign.Center)
        Text(this.option).fontSize(17)
          .onClick(() => {
            if (this.questionId==-1 || this.isEditing) { // 添加或者修改
              this.saveQuestion(); // 保存问答信息
            } else { // 查看详情
              this.option = '保存';
            }
            this.isEditing = !this.isEditing;
          })
      }
      .width('100%').height(60).padding(10)
      Divider().width('100%').color(Color.Gray).padding({left:10, right:10})

      if (this.isEditing) {
        Column() {
          Text('问题内容：').width('100%').fontSize(18).padding(5)
          TextArea({ text: $$this.question, placeholder: '请填写问题内容' })
            .width('100%').height(70)
            .fontSize(18).fontColor(Color.Black)
            .type(TextAreaType.NORMAL) // 输入文本类型。NORMAL表示普通文本
          Text('回答内容：').width('100%').fontSize(18).padding(5)
          TextArea({ text: $$this.answer, placeholder: '请填写回答内容' })
            .width('100%').height(70)
            .fontSize(18).fontColor(Color.Black)
            .type(TextAreaType.NORMAL) // 输入文本类型。NORMAL表示普通文本
        }
        .width('100%').padding(5)
      } else {
        Column() {
          Text('问题内容：').width('100%').fontSize(18).padding(5)
          Text(this.question).width('100%').height(70) .fontSize(18)
          Text('回答内容：').width('100%').fontSize(18).padding(5)
          Text(this.answer).width('100%').height(70).fontSize(18)
        }
        .width('100%').padding(5)
      }
    }
    .height('100%')
    .width('100%')
  }
}