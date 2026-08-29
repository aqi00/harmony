import { connection } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';

import { BridgeWeb, BridgeController, CallBackFunction, BridgeHandler, ExtendAction } from '@aqi00/jsbridge';

class BridgeRequest {
  methodName: string
  callbackName: string
  requestParams: Record<string, string>

  constructor(methodName: string, callbackName: string, requestParams: Record<string, string>) {
    this.methodName = methodName
    this.callbackName = callbackName
    this.requestParams = requestParams
  }
}

class BridgeResponse {
  isSuccess: boolean
  errorMessage: string
  responseParams: Record<string, string>

  constructor(isSuccess: boolean, errorMessage: string, responseParams: Record<string, string>) {
    this.isSuccess = isSuccess
    this.errorMessage = errorMessage
    this.responseParams = responseParams
  }
}

class NetworkInfo {
  networkType: number
  networkNameEN: string
  networkNameCN: string

  constructor(networkType: number, networkNameEN: string, networkNameCN: string) {
    this.networkType = networkType
    this.networkNameEN = networkNameEN
    this.networkNameCN = networkNameCN
  }
}

@Entry
@Component
struct WebBridgePage {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private localUrl = $rawfile('jsbridge/example.html'); // 测试网页文件
  // JS桥接控制器
  private bridge = new BridgeController();
  // 持有子组件方法的引用
  private extendAction: ExtendAction | null = null;

  // 检查Record变量是否包含指定键名
  containsKey(record: Record<string, string>, key: string): boolean {
    let keys: string[] = Object.keys(record)
    for (let k of keys) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  // 获取网络信息
  getNetworkInfo(): NetworkInfo {
    // 获取默认激活的网络句柄
    try {
      let netHandle = connection.getDefaultNetSync()
      // netId 为 0 表示当前无可用网络
      if (netHandle.netId === 0) {
        return new NetworkInfo(-2, 'none', '无可用网络')
      }
      // 获取该网络的能力集
      let caps = connection.getNetCapabilitiesSync(netHandle)
      // bearerTypes 数组中包含网络载体类型
      let bearerTypes: Array<connection.NetBearType> = caps.bearerTypes
      if (bearerTypes.length > 0) {
        // 解析完整的网络信息
        return this.parseNetworkInfo(bearerTypes[0])
      }
    } catch (err) {
      console.info(`获取默认网络失败. Code is ${err.code}, message is ${err.message}`);
    }
    return new NetworkInfo(-1, 'error', '错误网络')
  }

  // 解析完整的网络信息
  parseNetworkInfo(type: connection.NetBearType): NetworkInfo {
    switch (type) {
      case connection.NetBearType.BEARER_CELLULAR:
        return new NetworkInfo(type, 'mobile', '蜂窝网络')
      case connection.NetBearType.BEARER_WIFI:
        return new NetworkInfo(type, 'wifi', '无线局域网')
      case connection.NetBearType.BEARER_BLUETOOTH:
        return new NetworkInfo(type, 'bluetooth', '蓝牙网络')
      case connection.NetBearType.BEARER_ETHERNET:
        return new NetworkInfo(type, 'ethernet', '以太网网络')
      case connection.NetBearType.BEARER_VPN:
        return new NetworkInfo(type, 'vpn', '虚拟专用网络')
      default:
        return new NetworkInfo(type, 'unknown', '未知网络')
    }
  }

  aboutToAppear(): void {
    let bridgeHandler: BridgeHandler = {
      handler: (data: string, callback: CallBackFunction): void => {
        console.info(`JSBridge 调用，data: ${JSON.stringify(data)}`)
        let request = JSON.parse(JSON.stringify(data)) as BridgeRequest
        if (request.methodName==null && request.methodName==='') {
          console.error('JSBridge 请求格式错误')
          this.bridgeCallback(request!!.callbackName,
            new BridgeResponse(false, '请求格式错误', {} )
          )
          return
        } else {
          console.info(`JSBridge methodName: ${request.methodName}, callbackName: ${request.callbackName}`
          )
          this.processBridgeRequest(request)
        }
      }
    }
    this.bridge.registerHandler('JSBridge', bridgeHandler)
  }

  processBridgeRequest(request: BridgeRequest) {
    if (request.methodName === 'getNetworkInfo') {
      // 获取当前设备的网络信息
      let seq = ''
      if (request.requestParams != null && this.containsKey(request.requestParams, 'seq')) {
        seq = request.requestParams['seq']
      }
      console.info('getNetworkInfo seq：'+seq);
      let networkInfo = this.getNetworkInfo()
      console.info('getNetworkInfo networkInfo：'+networkInfo.networkNameCN);
      let responseParams: Record<string, string> = {}
      responseParams['networkType'] = ''+networkInfo.networkType
      responseParams['networkNameEN'] = networkInfo.networkNameEN
      responseParams['networkNameCN'] = networkInfo.networkNameCN
      this.bridgeCallback(
        request.callbackName,
        new BridgeResponse(true, '', responseParams)
      )
      return
    }
  }

  bridgeCallback(callbackName: string, response: BridgeResponse): void {
    let jsonResponse = JSON.stringify(response)
    console.info(`JSBridge 回调 callbackName:${callbackName} response:${jsonResponse}`)
    if (this.bridge == null) {
      console.info('bridgeCallback: Activity/WebView not available, skip')
      return
    }
    // 直接 JS 全局回调
    let js = 'window.JSBridge_onCallback(' + JSON.stringify(callbackName) + ', ' + jsonResponse + ');'
    console.info(`执行 JS: ${js}`)
    if (this.extendAction !== null) {
      this.extendAction(`javascript:${js}`)
    }
  }

  build() {
    Column() {
      BridgeWeb({
        src: this.localUrl,
        bridge: this.bridge,
        onRegister: (action: ExtendAction): void => {
          this.extendAction = action
        }
      })
        .width('100%').height('100%')
    }
    .width('100%')
  }
}