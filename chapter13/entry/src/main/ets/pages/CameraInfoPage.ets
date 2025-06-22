import { camera } from '@kit.CameraKit'
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct CameraInfoPage {
  context = this.getUIContext().getHostContext();
  @State message: string = ''; // 查看结果
  private torchModeArray: string[] = ['常关', '常开', '自动'];
  private positionTypeArray: string[] = ['未指定', '后置', '前置', '折叠态'];
  private cameraTypeArray: string[] = ['未指定', '广角', '超广角', '长焦', '带景深信息'];
  private connectTypeArray: string[] = ['内置', 'USB连接', '远程连接'];
  private sceneModeMap = new Map([ [1, '拍照'], [2, '录像'], [12, '安全相机'] ]);

  // 查看相机信息
  showCameraInfo() {
    let cameraManager = camera.getCameraManager(this.context) // 获取相机管理器
    let torchMode = this.torchModeArray[cameraManager.getTorchMode()]
    let deviceArray = cameraManager.getSupportedCameras()
    this.message = `相机的手电筒模式为${torchMode}，拥有${deviceArray.length}个摄像头，其中`
    for (let device of deviceArray) {
      this.message = this.message + `\n\t编号为${device.cameraId}的摄像头` +
        `相机位置为${this.positionTypeArray[device.cameraPosition]}，` +
        `相机类型为${this.cameraTypeArray[device.cameraType]}，` +
        `连接类型为${this.connectTypeArray[device.connectionType]}，` +
        `旋转角度为${device.cameraOrientation}度，支持的拍摄模式包括：`
      let modeArray = cameraManager.getSupportedSceneModes(device);
      for (let mode of modeArray) {
        this.message = this.message + `${this.sceneModeMap.get(mode)} `
      }
    }
  }

  build() {
    Column() {
      Button('查看相机信息').width('100%').fontSize(18)
        .onClick(() => {
          this.showCameraInfo() // 查看相机信息
        })
      Text(this.message).width('100%').padding(5).fontSize(18)
    }
    .width('100%').height('100%')
  }
}