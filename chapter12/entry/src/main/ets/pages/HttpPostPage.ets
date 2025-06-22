import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../constant/Constants';

@Entry
@Component
struct HttpPostPage {
  // 注意这里的URL地址要换成读者在自己WiFi环境下的IP和端口
  private url: string = Constants.URL_PREFIX + 'login'; // 登录接口的完整地址
  @State username: string = ''; // 用户名
  @State password: string = ''; // 密码
  @State result: string = ''; // HTTP调用结果

  // 执行登录请求
  login() {
    // 每个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 订阅HTTP响应头事件
    httpRequest.on('headersReceive', (header: Object) => {
      console.info('header: ' + JSON.stringify(header));
    });
    let jsonText = `{'username': '${this.username}', 'password': '${this.password}'}`;
    console.info('jsonText: '+jsonText);
    let options: http.HttpRequestOptions ={
      method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
      extraData: jsonText, // 当HTTP请求为POST、PUT等方法时，此字段为HTTP的请求内容
      expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
      usingCache: true, // 可选，默认为true
      header: { // 请求包头
        //'Accept-Language': 'zh-CN',
        'Content-Type': 'application/json; charset=utf-8',
        //'Accept': 'application/json; charset=utf-8'
      },
      readTimeout: 12000, // 可选，默认为60000ms
      connectTimeout: 12000, // 可选，默认为60000ms
    }
    // 根据URL地址，发起HTTP网络请求，使用callback方式作为异步回调
    httpRequest.request(this.url, options,
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          this.result = 'HTTP接口返回内容如下：\n'+data.result
          // data.result为HTTP响应内容，可根据业务需要进行解析
          console.info('Result:' + JSON.stringify(data.result));
          console.info('responseCode:' + JSON.stringify(data.responseCode));
          console.info('resultType:' + JSON.stringify(data.resultType));
          // data.header为HTTP响应头，可根据业务需要进行解析
          console.info('header:' + JSON.stringify(data.header));
          console.info('cookies:' + JSON.stringify(data.cookies));
        } else {
          console.error('error:' + JSON.stringify(err));
        }
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript对象
        httpRequest.destroy();
      })
  }

  build() {
    Column() {
      Row() {
        Text('用户名：').fontSize(18)
        TextInput({ text: $$this.username, placeholder: '请输入用户名' })
          .fontSize(18).type(InputType.Normal)
          .layoutWeight(1).height(40)
      }.margin(5)
      Row() {
        Text('密　码：').fontSize(18)
        TextInput({ text: $$this.password, placeholder: '请输入密码' })
          .fontSize(18).type(InputType.Password)
          .layoutWeight(1).height(40)
          .maxLength(8).showPasswordIcon(true)
          .inputFilter('[a-zA-Z0-9~!@#$%^&*()_+-=]')
      }.margin(5)
      Button('登录').fontSize(18).width('100%')
        .onClick(() => {
          this.login() // 执行登录请求
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%')
  }
}