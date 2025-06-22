import { image } from '@kit.ImageKit';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { Point } from '../entity/Point'

@Component
export struct CoordinateView {
  context = this.getUIContext();
  private canvas: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  @Consume @Watch('onDataChanged') point: Point;

  onDataChanged() {
    console.info('onDataChanged')
    this.drawCanvas(this.point)
  }

  getPixelMap(res: Resource): image.PixelMap {
    let helper = new util.Base64Helper();
    let context = this.getUIContext().getHostContext() as common.Context;
    let base64 = context.resourceManager.getMediaContentBase64Sync(res);
    let symbol = 'base64,'
    let pos = base64.indexOf(symbol)
    if (pos!=undefined && pos>0) {
      base64 = base64.substring(pos+symbol.length)
    }
    //console.info(base64);
    // 使用decodeSync对base64字符串解码时，传入的base64字符串不能有'data:image/jpeg;base64,'这样的前缀
    let buffer: ArrayBuffer = helper.decodeSync(base64, util.Type.MIME).buffer as ArrayBuffer;
    let imageSource = image.createImageSource(buffer);
    let pixelmap = imageSource.createPixelMapSync()
    return pixelmap
  }

  // 根据半径、角度、线长，计算该点的横坐标
  private getXpos(radius: number, angle: number, length: number): number {
    return radius + this.getCos(angle) * length;
  }

  // 根据半径、角度、线长，计算该点的纵坐标
  private getYpos(radius: number, angle: number, length: number): number {
    return radius + this.getSin(angle) * length;
  }

  // 获得指定角度的正弦值
  private getSin(angle: number): number {
    return Math.sin(Math.PI * angle / 180.0);
  }

  // 获得指定角度的余弦值
  private getCos(angle: number): number {
    return Math.cos(Math.PI * angle / 180.0);
  }

  drawCircle(canvas: CanvasRenderingContext2D, x: number, y: number, radius: number) {
    canvas.beginPath() // 创建新的绘制路径
    canvas.arc(x, y, radius, 0, 6.28)
    canvas.stroke()
  }

  drawLine(canvas: CanvasRenderingContext2D, begin_x: number, begin_y: number, end_x: number, end_y: number) {
    canvas.beginPath() // 创建新的绘制路径
    canvas.moveTo(begin_x, begin_y)
    canvas.lineTo(end_x, end_y)
    canvas.stroke()
  }

  private sideLength = 0;
  private scaleLength = 25/this.context.vp2px(0.5); // 刻度线的长度
  private borderRatio = 0.9; // 边界的倍率，比如只在整个区域的90%内部绘图
  drawCanvas(point: Point) {
    // 每次绘制前都要先清空画布
    this.canvas.clearRect(0, 0, this.sideLength, this.sideLength)
    let radius = this.sideLength / 2
    let margin = radius / 10
    let bgImage = this.getPixelMap($r('app.media.compass_bg'))
    let ball = this.getPixelMap($r('app.media.satellite_europe'))
    let iconWidth = this.context.vp2px(6)
    this.canvas.strokeStyle = '#00ff00'
    this.canvas.lineWidth = this.context.vp2px(0.5)
    // 在画布上绘制罗盘背景
    this.canvas.drawImage(bgImage, 0, 0, this.sideLength, this.sideLength)
    // 以下在画布上绘制各种半径的圆圈
    this.drawCircle(this.canvas, radius, radius, radius * 3 / 10)
    this.drawCircle(this.canvas, radius, radius, radius * 5 / 10)
    this.drawCircle(this.canvas, radius, radius, radius * 7 / 10)
    this.drawCircle(this.canvas, radius, radius, radius * 9 / 10)
    // 在画布上绘制罗盘的中央垂直线
    this.drawLine(this.canvas, radius, margin, radius, this.sideLength - margin)
    // 在画布上绘制罗盘的中央水平线
    this.drawLine(this.canvas, margin, radius, this.sideLength - margin, radius)
    // 画罗盘的刻度
    for (let i = 0; i < 360; i += 30) {
      let angle = (i + 90) % 360;
      // 在画布上绘制刻度线条
      this.drawLine(this.canvas,
        this.getXpos(radius, angle, radius * this.borderRatio),
        this.getYpos(radius, angle, radius * this.borderRatio),
        this.getXpos(radius, angle, (radius - this.scaleLength) * this.borderRatio),
        this.getYpos(radius, angle, (radius - this.scaleLength) * this.borderRatio)
      )
    }
    let left = radius - this.getSin(this.point.x) * radius * this.borderRatio
    let top = radius - this.getSin(this.point.y) * radius * this.borderRatio
    // 在画布上绘制滚珠图标
    this.canvas.drawImage(ball, left - iconWidth/2, top - iconWidth/2, iconWidth, iconWidth);
  }

  build() {
    Column() {
      Canvas(this.canvas)
        .width('100%').height('100%').backgroundColor(Color.White)
        // 组件尺寸或者组件位置发生变化时触发
        .onAreaChange((oldValue: Area, newValue: Area) => {
          console.info(`onAreaChange, oldValue is ${JSON.stringify(oldValue)} value is ${JSON.stringify(newValue)}`)
          this.sideLength = Math.min(Number(newValue.width), Number(newValue.height))
          this.drawCanvas(this.point)
        })
    }
    .width('100%').height('100%')
  }
}
