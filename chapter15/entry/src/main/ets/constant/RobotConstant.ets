import { util } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { pinyin4js } from '@ohos/pinyin4js'

import { Utils } from '../utils/Utils';
import { NumberUtil } from '../utils/NumberUtil';
import { PoemInfo } from '../entity/PoemInfo';
import { PoemDB } from '../entity/PoemDB';
import { QuestionInfo } from '../entity/QuestionInfo';
import { QuestionDB } from '../entity/QuestionDB';
import { CityInfo } from '../entity/CityInfo';
import { SeqInfo } from '../entity/SeqInfo';

export class RobotConstant {
  public static TEMPLETE_FILE: string = 'system_question.txt'
  public static SAMPLE_FILES: string[] = ['welcome.mp3', 'happy.mp3', 'shy.mp3', 'cry.mp3', 'angry.mp3',
    'regret.mp3', 'naive.mp3', 'goodbye.mp3', 'who.mp3', 'name.mp3', 'age.mp3']
  public static SYSTEM_ANSWERS: string[] = [
    '您好，很高兴为您服务。有什么可以帮您的呢？',
    '真的嘛，我好开心呢，嘻嘻嘻。',
    '哎哟，不要摸我啦，人家会害羞的呀。',
    '是吗？我真的好伤心呀，呜呜呜。',
    '哼，我不高兴，不理你了。',
    '很抱歉，需要先打开定位和网络，我才知道地点和天气哦。',
    '我还不知道这个问题呢，你能教我吗？',
    '非常感谢您的倾听，下回再见噢。',
    '我是小小机器人呀。',
    '我的名字叫甜甜。',
    '我今年六岁了。']
  public static SAMPLE_PATHS: string[] = [] // 样本语音的文件路径
  public static POETRY_FILE: string = 'ancient_poetry.txt'
  public static RECITE_PART: string = '背诵|朗诵|朗读|诵读|会背|你会|备送'
  public static RECITE_PATTERN: string = '.*(' + this.RECITE_PART + ').*'

  // 把assets目录的样本音频复制到存储卡
  public static copySampleFiles(context: common.UIAbilityContext) {
    for (let i = 0; i < RobotConstant.SAMPLE_FILES.length; i++) {
      let sampleFile = 'robot/' + RobotConstant.SAMPLE_FILES[i]
      let samplePath = util.format('%s/%s', context.resourceDir, sampleFile)
      //AssetsUtil.Assets2Sd(context, sampleFile, samplePath)
      RobotConstant.SAMPLE_PATHS.push(samplePath)
    }
  }

  // 初始化系统设定的问题
  public static initSystemQuestion(context: common.UIAbilityContext, questionDao: QuestionDB) {
    let templateFile = 'robot/' + RobotConstant.TEMPLETE_FILE
    let templatePath = util.format('%s/%s', context.resourceDir, templateFile)
    console.info('SystemQuestion templatePath=' + templatePath)
    if (fileIo.accessSync(templatePath)) {
      let systemList: QuestionInfo[] = []
      //AssetsUtil.Assets2Sd(context, templateFile, templatePath)
      let content = fileIo.readTextSync(templatePath)
      console.info('SystemQuestion content.length=' + content.length)
      //let content = FileUtil.openText(templatePath)
      let lines = content.split('\n')
      for (let line of lines) {
        let items = line.split(' ')
        systemList.push(new QuestionInfo(items[0], items[1], 0))
      }
      questionDao.insertQuestionList(systemList) // 插入多条问答信息
      console.info('SystemQuestion systemList.length=' + systemList.length)
    }
  }

  // 初始化古诗数据
  public static initPoetryData(context: common.UIAbilityContext, poemDao: PoemDB) {
    let templateFile = 'robot/' + RobotConstant.POETRY_FILE
    let templatePath = util.format('%s/%s', context.resourceDir, templateFile)
    console.info('PoetryData templatePath=' + templatePath)
    if (fileIo.accessSync(templatePath)) {
      let poemList: PoemInfo[] = []
      let content = fileIo.readTextSync(templatePath)
      console.info('SystemQuestion content.length=' + content.length)
      let lines = content.split('\n')
      for (let line of lines) {
        let items = line.split('\|')
        if (items.length > 3) {
          poemList.push(new PoemInfo(items[0], items[1], items[2], items[3]))
        }
      }
      poemDao.insertPoemList(poemList) // 插入多条诗歌信息
      console.info('SystemQuestion poemList.length=' + poemList.length)
    }
  }

  // 查找该诗在列表中的位置
  public static searchPoemPos(text: string, beginPos: number, poemList: PoemInfo[]): number {
    let pos = -1
    if (beginPos != -1 && beginPos < poemList.length - 1) {
      let poemNext = poemList[beginPos+1]
      if (text.includes(poemNext.title)) { // 区分其一和其二
        pos = beginPos + 1
      }
      return pos
    }
    let posList: number[] = []
    for (let i = beginPos + 1; i < poemList.length; i++) {
      let poem = poemList[i]
      if (text.includes(poem.author)) {
        posList.push(i)
        let title = poem.title.length <= 1 ?
          poem.title : poem.title.substring(0, 2)
        if (text.includes(title)) {
          return i
        }
      }
      if (poem.author.length>2) {
        let author2 = poem.author.slice(0, -1)
        if (text.includes(author2)) {
          posList.push(i)
          let title = poem.title.length <= 1 ?
            poem.title : poem.title.substring(0, 2)
          if (text.includes(title)) {
            return i
          }
        }
      }
    }
    let dePos = text.lastIndexOf('的')
    console.info('dePos=' + dePos)
    if (dePos >= 0 && dePos < text.length - 1) {
      let hanzi = text.substring(dePos + 1)
      let pinyin = pinyin4js.convertToPinyinString(hanzi, '', pinyin4js.WITHOUT_TONE);
      console.info('pinyin=' + pinyin)
      if (pinyin != null && pinyin.length > 0) {
        for (let j = 0; j < posList.length; j++) {
          let poem = poemList[posList[j]]
          console.info('pinyin=' + pinyin + ',getPinyin=' + poem.pinyin)
          if (pinyin.includes(poem.pinyin)) {
            pos = posList[j]
            return pos
          }
        }
        pinyin = pinyin.replace('shi','si')
        for (let j = 0; j < posList.length; j++) {
          let poem = poemList[posList[j]]
          console.info('pinyin=' + pinyin + ',getPinyin=' + poem.pinyin)
          if (pinyin.includes(poem.pinyin)) {
            pos = posList[j]
            return pos
          }
        }
        pinyin = pinyin.replace('chi','ci')
        for (let j = 0; j < posList.length; j++) {
          let poem = poemList[posList[j]]
          console.info('pinyin=' + pinyin + ',getPinyin=' + poem.pinyin)
          if (pinyin.includes(poem.pinyin)) {
            pos = posList[j]
            return pos
          }
        }
        pinyin = pinyin.replace('zhi','zi')
        for (let j = 0; j < posList.length; j++) {
          let poem = poemList[posList[j]]
          console.info('pinyin=' + pinyin + ',getPinyin=' + poem.pinyin)
          if (pinyin.includes(poem.pinyin)) {
            pos = posList[j]
            return pos
          }
        }
      }
    }
    return pos
  }

  // 判断回答的序号和内容
  public static judgeAnswerResult(question: string, answer: string, cityInfo: CityInfo): SeqInfo {
    let voiceSeq = -1
    let tempText = ''
    if (answer.includes('askWho')) { // 问个人
      voiceSeq = 8
    } else if (answer.includes('askName')) { // 问名字
      voiceSeq = 9
    } else if (answer.includes('askAge')) { // 问年龄
      voiceSeq = 10
    } else if (answer.includes('askDate')) { // 问日期
      tempText = '今天是' + Utils.getNowDateCN()
    } else if (answer.includes('askTime')) { // 问时间
      tempText = '现在是' + Utils.getNowTimeCN()
    } else if (answer.includes('askWeek')) { // 问星期
      tempText = '今天是' + Utils.getNowWeekCN()
    } else if (answer.includes('askWhere')) { // 问家乡
      if (cityInfo == null) {
        voiceSeq = 5
      } else {
        tempText = util.format('我是%s人。', cityInfo.city_name.replace('市', ''))
      }
    } else if (answer.includes('askAddress')) { // 问地址
      if (cityInfo == null) {
        voiceSeq = 5
      } else {
        tempText = util.format('我住在%s。', cityInfo.address)
      }
    } else if (answer.includes('askWeather')) { // 问天气
      if (cityInfo == null || cityInfo.weather_info == null) {
        voiceSeq = 5
      } else {
        tempText = util.format('今天天气是%s，吹%s风，风力%s级。',
          cityInfo.weather_info.weather,
          cityInfo.weather_info.winddirection,
          cityInfo.weather_info.windpower)
      }
    } else if (answer.includes('askTemperature')) { // 问气温
      if (cityInfo == null || cityInfo.weather_info == null) {
        voiceSeq = 5
      } else {
        tempText = util.format('现在气温是%s度，湿度是%s%%。',
          cityInfo.weather_info.temperature,
          cityInfo.weather_info.humidity)
      }
    } else if (answer.includes('makeHappy')) { // 让它开心
      voiceSeq = 1
    } else if (answer.includes('makeCry')) { // 让它哭泣
      voiceSeq = 3
    } else if (answer.includes('makeAngry')) { // 让它愤怒
      voiceSeq = 4
    } else if (answer.includes('sayGoodbye')) { // 与它再见
      voiceSeq = 7
    } else if (answer.includes('plusNumber')) { // 整数相加
      let operands = NumberUtil.getOperands(question.replace('+','加'), '加')
      if (operands == null || operands.length < 2) {
        console.info(answer+' operands is null: '+question)
        voiceSeq = 6
      } else {
        for (let item of operands) {
          console.info('item='+item)
        }
        tempText = util.format('%d加%d等于%d。', operands[0], operands[1], operands[0] + operands[1])
      }
    } else if (answer.includes('minusNumber')) { // 整数相减
      let operands = NumberUtil.getOperands(question.replace('-','减'), '减')
      if (operands == null || operands.length < 2) {
        console.info(answer+' operands is null: '+question)
        voiceSeq = 6
      } else {
        for (let item of operands) {
          console.info('item='+item)
        }
        tempText = util.format('%d减%d等于%d。', operands[0], operands[1], operands[0] - operands[1])
      }
    } else if (answer.includes('multiplyNumber')) { // 整数相乘
      let operands = NumberUtil.getOperands(question.replace('×','乘'), '乘')
      if (operands == null || operands.length < 2) {
        console.info(answer+' operands is null: '+question)
        voiceSeq = 6
      } else {
        for (let item of operands) {
          console.info('item='+item)
        }
        tempText = util.format('%d乘以%d等于%d。', operands[0], operands[1], operands[0] * operands[1])
      }
    } else if (answer.includes('divideNumber')) { // 整数相除
      let operands = NumberUtil.getOperands(question.replace('÷','除'), '除')
      if (operands == null || operands.length < 2) {
        console.info(answer+' operands is null: '+question)
        voiceSeq = 6
      } else if (operands[1] == 0) { // 除数为零
        tempText = '小朋友，除数不能为零喔。'
      } else { // 除数非零
        for (let item of operands) {
          console.info('item='+item)
        }
        let quotient = 1.0 * operands[0] / operands[1]
        let result = ''
        if (Number.isInteger(quotient)) {
          result = ''+quotient
        } else {
          // 去掉小数字符串末尾的0
          result = NumberUtil.removeTailZero(quotient.toFixed(6))
        }
        tempText = util.format('%d除以%d等于%s。', operands[0], operands[1], result)
      }
    }
    return new SeqInfo(voiceSeq, tempText)
  }
}