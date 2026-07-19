
export class Utils {

  public static getNowDatetime() {
    let date = new Date()
    let formattedDatetime = '' + date.getFullYear() +
      String(date.getMonth() + 1).padStart(2, '0') +
      String(date.getDate()).padStart(2, '0') +
      String(date.getHours()).padStart(2, '0') +
      String(date.getMinutes()).padStart(2, '0') +
      String(date.getSeconds()).padStart(2, '0')
    return formattedDatetime
  }

  // public static getNowDatetime() {
  //   let date = new Date()
  //   let formattedDatetime = util.format('%d%d%d%d%d%d',
  //     date.getFullYear(), date.getMonth()+1, date.getDate(),
  //     date.getHours(), date.getMinutes(), date.getSeconds())
  //   // let formattedDatetime = util.format('%d%02d%02d%02d%02d%02d',
  //   //   date.getFullYear(), date.getMonth()+1, date.getDate(),
  //   //   date.getHours(), date.getMinutes(), date.getSeconds())
  //   return formattedDatetime
  // }

  public static getFormatDatetime(utc: number) {
    let date = new Date(utc)
    let formattedDatetime = '' + date.getFullYear() + '-' +
    String(date.getMonth() + 1).padStart(2, '0') + '-' +
    String(date.getDate()).padStart(2, '0') + ' ' +
    String(date.getHours()).padStart(2, '0') + ':' +
    String(date.getMinutes()).padStart(2, '0') + ':' +
    String(date.getSeconds()).padStart(2, '0')
    return formattedDatetime
  }

  public static getNowDateCN() {
    let date = new Date()
    let formattedDatetime = '' + String(date.getMonth() + 1) + '月' + String(date.getDate()) + '日'
    return formattedDatetime
  }

  public static getNowTimeCN() {
    let date = new Date()
    let formattedDatetime = '' + String(date.getHours()) + '点' + String(date.getMinutes()) + '分'
    return formattedDatetime
  }

  private static WEEK_NUM: string[] = ['天', '一', '二', '三', '四', '五', '六'];

  public static getNowWeekCN() {
    let date = new Date()
    return '星期' + Utils.WEEK_NUM[date.getDay()];
  }

}