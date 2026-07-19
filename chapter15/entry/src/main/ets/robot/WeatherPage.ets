import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { UrlConstant } from '../constant/UrlConstant';
import { WeatherResp } from '../entity/WeatherResp';
import { CityResp } from '../entity/CityResp';

@Entry
@Component
struct WeatherPage {
  @State index: number = 0;
  private cityArray: SelectOption[] = [
    { value: '北京' }, { value: '上海' }, { value: '天津' }, { value: '重庆' },
    { value: '广州' }, { value: '成都' }, { value: '武汉' }, { value: '南京' },
    { value: '杭州' }, { value: '西安' }, { value: '长沙' }, { value: '郑州' },
    { value: '合肥' }, { value: '福州' }, { value: '济南' }, { value: '沈阳' },
    { value: '哈尔滨' }, { value: '长春' }, { value: '石家庄' }, { value: '太原' },
    { value: '南昌' }, { value: '昆明' }, { value: '贵阳' }, { value: '南宁' },
    { value: '兰州' }, { value: '呼和浩特' }, { value: '台北' }, { value: '海口' },
    { value: '西宁' }, { value: '银川' }, { value: '拉萨' }, { value: '乌鲁木齐' },
    { value: '香港' }, { value: '澳门' }, { value: '大连' }, { value: '青岛' },
    { value: '宁波' }, { value: '厦门' }, { value: '深圳' }, { value: '高雄' } ];
  @State result: string = '';

  // 请求城市接口
  queryCity(city: string) {
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
      },
    }
    let url = util.format(UrlConstant.url_city, city)
    // 根据URL地址，发起HTTP网络请求，使用callback方式作为异步回调
    httpRequest.request(url, options,
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          let resp = data.result.toString()
          let cityResp = JSON.parse(resp) as CityResp // 把JSON字符串解析为对象实例
          if (cityResp.status==='1' && cityResp.districts!=null && cityResp.districts.length>0) {
            let cityInfo = cityResp.districts[0]
            this.queryWeather(cityInfo.adcode)
          }
          //this.result = '城市接口返回内容如下：\n'+data.result.toString()
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

  // 请求天气接口
  queryWeather(city: string) {
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
      },
    }
    let url = util.format(UrlConstant.url_weather, city)
    // 根据URL地址，发起HTTP网络请求，使用callback方式作为异步回调
    httpRequest.request(url, options,
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          let resp = data.result.toString()
          let weatherResp = JSON.parse(resp) as WeatherResp // 把JSON字符串解析为对象实例
          if (weatherResp.status==='1' && weatherResp.lives!=null && weatherResp.lives.length>0) {
            let weatherInfo = weatherResp.lives[0]
            this.result = `${weatherInfo.city}天气：${weatherInfo.weather}，\n气温：${weatherInfo.temperature}度，\n` +
              `湿度：${weatherInfo.humidity}，\n风向：${weatherInfo.winddirection}，\n` +
              `风力：${weatherInfo.windpower}级，\n报告时间：${weatherInfo.reporttime}。\n`
          }
          //this.result = '天气接口返回内容如下：\n'+data.result.toString()
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
        Text('请选择城市：').fontSize(18)
        Select(this.cityArray).font({ size: 18 }).layoutWeight(1)
          .selected($$this.index).value(this.cityArray[this.index].value)
      }.width('100%').padding(5)
      Button('查询城市天气').width('100%').fontSize(18)
        .onClick(() => {
          this.queryCity(this.cityArray[this.index].value.toString())
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .height('100%')
    .width('100%')
  }
}