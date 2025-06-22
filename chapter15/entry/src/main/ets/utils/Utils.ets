
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

}