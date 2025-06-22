import cryptoFramework from '@ohos.security.cryptoFramework'
import { buffer } from '@kit.ArkTS';

export class ChatUtil {

  static mPortraitArray: Resource[] = [
    $r('app.media.portrait01'), $r('app.media.portrait02'), $r('app.media.portrait03'), $r('app.media.portrait04'),
    $r('app.media.portrait05'), $r('app.media.portrait06'), $r('app.media.portrait07'), $r('app.media.portrait08'),
    $r('app.media.portrait09'), $r('app.media.portrait10'), $r('app.media.portrait11'), $r('app.media.portrait12'),
    $r('app.media.portrait13'), $r('app.media.portrait14'), $r('app.media.portrait15'), $r('app.media.portrait16')]
  // static mPortraitArray: Resource[] = [
  //   $r('app.media.portrait01'), $r('app.media.portrait02'), $r('app.media.portrait03'), $r('app.media.portrait04'),
  //   $r('app.media.portrait05'), $r('app.media.portrait06'), $r('app.media.portrait07'), $r('app.media.portrait08')]
  // static mPortraitArray: Resource[] = [
  //   $r('app.media.avatar01'), $r('app.media.avatar02'), $r('app.media.avatar03'), $r('app.media.avatar04'),
  //   $r('app.media.avatar05'), $r('app.media.avatar06'), $r('app.media.avatar07'), $r('app.media.avatar08')]

  public static getPortraitByName(nickName: string, callback: Function) {
    let md = cryptoFramework.createMd('MD5');
    md.update({ data: new Uint8Array(buffer.from(nickName, 'utf-8').buffer) }, (err,) => {
      md.digest((err, digestOutput) => {
        let md5str = Array.from(digestOutput.data).map(byte => byte.toString(16).padStart(2, '0')).join('').toUpperCase();
        console.info('getPortraitByName: MD result: ' + md5str);
        let lastChar = md5str.charCodeAt(md5str.length-1)
        console.info('lastChar='+lastChar+', A='+'A'.charCodeAt(0)+', 0='+'0'.charCodeAt(0));
        let pos = lastChar>='A'.charCodeAt(0) ? lastChar-'A'.charCodeAt(0)+10 : lastChar-'0'.charCodeAt(0)
        //pos = Math.floor(pos/2)
        console.info('getPortraitByName: pos: ' + pos);
        callback(ChatUtil.mPortraitArray[pos])
      });
    });
  }
}
