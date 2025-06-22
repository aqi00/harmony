import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import axios, { AxiosResponse } from '@ohos/axios';

@Entry
@Component
struct HttpGetPage {
  private stockArray: Array<SelectOption> = [ { value: '新浪股指' }, { value: '腾讯股指' }, { value: '搜狐股指' } ];
  private urlArray: string[] = [
    'https://hq.sinajs.cn/list=s_sh000001',
    'https://qt.gtimg.cn/q=s_sh000001',
    'https://q.stock.sohu.com/hisHq?code=cn_000001&start=20240306&end=20240306'
  ];
  private charsetArray: string[] = [ 'gb18030', 'gbk', 'gbk' ];
  @State index: number = 0;;
  private url = 'https://q.stock.sohu.com/hisHq?code=cn_000001&start=20240306&end=20240306';
  @State result: string = ''; // HTTP请求结果

  // 请求股指接口
  queryStock() {
    // 每个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 订阅HTTP响应头事件
    httpRequest.on('headersReceive', (header: Object) => {
      console.info('header: ' + JSON.stringify(header));
    });
    let options: http.HttpRequestOptions ={
      method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
      header: { // 请求包头
        'Accept-Language': 'zh-CN',
        'Referer': 'https://finance.sina.com.cn', // 新浪财经接口需要
        //'Content-Type': 'application/json; charset=utf-8',
        //'Accept': 'application/json; charset=utf-8'
      },
      //readTimeout: 60000, // 可选，默认为60000ms
      //connectTimeout: 60000, // 可选，默认为60000ms
    }
    // // requestInStream与request的区别如下：
    // // 1、request接口只有5M的数据，如果响应大于5M要用requestInStream
    // // 2、request接口是短连接，而requestInStream是长连接
    // // 3、request接口可直接获得返回内容，而requestInStream需要另外订阅dataReceive、dataEnd、dataReceiveProgress等事件
    // // https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/http-request-V5#requestinstream%E6%8E%A5%E5%8F%A3%E5%BC%80%E5%8F%91%E6%AD%A5%E9%AA%A4
    // httpRequest.requestInStream(this.url, options,
    //   (err: BusinessError, data: number) => {
    //     if (!err) {
    //       console.info("requestInStream OK! ResponseCode is " + JSON.stringify(data));
    //     } else {
    //       console.error("requestInStream ERROR : err = " + JSON.stringify(err));
    //     }
    //   })
    // 根据URL地址，发起HTTP网络请求，使用callback方式作为异步回调
    httpRequest.request(this.urlArray[this.index], options,
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          this.result = '股指接口返回内容如下：\n'+data.result.toString()
          // data.result为HTTP响应内容，可根据业务需要进行解析
          console.info('Result:' + JSON.stringify(data.result));
          console.info('responseCode:' + JSON.stringify(data.responseCode));
          console.info('resultType:' + JSON.stringify(data.resultType));
          // data.header为HTTP响应头，可根据业务需要进行解析
          console.info('header:' + JSON.stringify(data.header));
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
        Text('请选择股指接口：').fontSize(18)
        Select(this.stockArray).font({ size: 18 }).layoutWeight(1)
          .selected($$this.index)
          .value(this.stockArray[this.index].value)
      }.width('100%').padding(5)
      Row() {
        Button('查询股指接口').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.queryStock() // 请求股指接口
          })
        Button('Axios查询股指接口').fontSize(18).layoutWeight(1)
          .onClick(() => {
            this.queryStockByAxios() // Axios方式请求股指接口
          })
      }.width('100%')
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%')
  }

  // Axios方式请求股指接口
  queryStockByAxios() {
    axios<string, AxiosResponse<string>, null>({
      method: 'get', // 请求方式
      url: this.urlArray[this.index], // 请求地址
      connectTimeout: 3000, // 连接超时时间
      headers: { // 请求包头
        'Accept-Language': 'zh-CN',
        'Referer': 'https://finance.sina.com.cn', // 新浪财经接口需要
      },
      // 在使用util.TextDecoder方法时，编码和解码格式要一致，所以在获取时需将数据类型设置为ARRAY_BUFFER，否则会出现乱码。
      responseType: 'ARRAY_BUFFER' // 应答类型
    })
      .then((resp: AxiosResponse) => {
        // 首先使用create构造TextDecoder实例，设置指定的字符编码格式。
        let textDecoder = util.TextDecoder.create(this.charsetArray[this.index], { ignoreBOM: true });
        // 其次使用decodeToString方法通过解码输入的参数，输出对应UTF-8格式的文本字符串。其中传入的参数必须为Uint8Array格式，因此需将获取的数据使用Uint8Array方法转换数组类型。
        let result = new Uint8Array(resp.data);
        let resultString = textDecoder.decodeToString(result, { stream: false });
        console.info('resultString='+resultString)
        // 解析json字符串。
        this.result = 'Axios查询股指接口返回内容如下：\n'+resultString
      })
  }
}