import { sensor } from '@kit.SensorServiceKit';

const CENTER_X = 140;
const CENTER_Y = 140;
const MAX_RADIUS = 135;
const BUBBLE_RADIUS = 20;
const CIRCLES_NUM = 4;
const OUTER_LINE_WIDTH = 4;
const INNER_LINE_WIDTH = 2;
const MAX_OFFSET = MAX_RADIUS - BUBBLE_RADIUS - OUTER_LINE_WIDTH / 2;

@Entry
@Component
struct SensorOrientationPage {
  context = this.getUIContext();
  
  @State bubbleX: number = 0; // 气泡X坐标
  @State originBubbleX: number = 0;
  @State bubbleY: number = 0; // 气泡Y坐标
  @State originBubbleY: number = 0;
  @State pitch: number = 0;
  @State threshold: number = 0.1;
  @State roll: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvas: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  aboutToAppear(): void {
    // 注册方向传感器监听
    sensor.on(sensor.SensorId.ORIENTATION, (data) => {
      let pitch = data.beta; // 俯仰角
      let roll = data.gamma; // 侧倾角
      if (Math.abs(pitch - this.pitch) < this.threshold && Math.abs(roll - this.roll) < this.threshold) {
        return;
      }
      this.pitch = pitch;
      this.roll = roll
      this.originBubbleX = this.getOrigin(roll);
      this.originBubbleY = this.getOrigin(pitch);
      // 计算气泡位置（根据屏幕尺寸调整比例）
      this.bubbleX = this.originBubbleX / 90 * MAX_OFFSET;
      this.bubbleY = this.originBubbleY / 90 * MAX_OFFSET;
      this.updateBubblePosition();
    }, { interval: 1000000 });
  }

  aboutToDisappear(): void {
    // 注销方向传感器监听
    sensor.off(sensor.SensorId.ORIENTATION);
  }

  updateBubblePosition() {
    // 限制气泡在圆盘范围内
    this.bubbleX = Math.min(Math.max(this.bubbleX, -MAX_OFFSET), MAX_OFFSET);
    this.bubbleY = Math.min(Math.max(this.bubbleY, -MAX_OFFSET), MAX_OFFSET);
    let currentDistance = Math.sqrt(this.bubbleX**2 + this.bubbleY**2);
    // 如果超出圆形范围，按比例缩放坐标
    if (currentDistance > MAX_OFFSET) {
      let scale = MAX_OFFSET / currentDistance;
      this.bubbleX *= scale;
      this.bubbleY *= scale;
    }
    this.canvas.reset();
    this.onDraw(this.canvas)
  }

  build() {
    Column() {
      Row() {
        Text('水平仪').fontSize(24).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      Canvas(this.canvas)
        .onReady(() => {
          this.onDraw(this.canvas);
        })
        .width(280).height(280).margin({ top: 90 })
        .backgroundColor($r('app.color.start_window_background'))

      Button(`X:${this.originBubbleX.toFixed(1)}°       Y:${(-this.originBubbleY).toFixed(1)}°`)
        .width(270).height(68).margin({ top: 44 })
        .type(ButtonType.Normal).borderRadius(16).fontSize(26)

    }
    .padding({ top: this.context.px2vp(this.topRectHeight), bottom: this.context.px2vp(this.bottomRectHeight) })
  }

  // 绘制水平仪
  onDraw(canvas: CanvasRenderingContext2D) {
    // 绘制背景
    for (let i = 0; i < CIRCLES_NUM; i++) {
      let radius = (i + 1) * (MAX_RADIUS / CIRCLES_NUM);
      canvas.beginPath();
      canvas.arc(CENTER_X, CENTER_Y, radius, 0, Math.PI * 2);
      canvas.strokeStyle = i === CIRCLES_NUM - 1 ? Color.Blue : 'rgba(135, 206, 250, 1.00)';
      canvas.lineWidth = i === CIRCLES_NUM - 1 ? OUTER_LINE_WIDTH : INNER_LINE_WIDTH;
      canvas.stroke(); // 绘制边框
    }
    // 绘制气泡
    canvas.beginPath();
    canvas.arc(CENTER_X + this.bubbleX, CENTER_Y + this.bubbleY, BUBBLE_RADIUS, 0, Math.PI * 2);
    canvas.fillStyle = 'rgb(100, 187, 92)';
    canvas.fill();
    // 添加左上白色弧形
    canvas.beginPath();
    canvas.arc(
      CENTER_X + this.bubbleX,
      CENTER_Y + this.bubbleY,
      BUBBLE_RADIUS * 0.9, // 稍小于原圆半径
      Math.PI * 1, // 起始角度
      Math.PI * 1.05, // 结束角度
      false // 顺时针绘制
    );
    canvas.strokeStyle = 'white';
    canvas.lineWidth = 2;
    canvas.lineCap = 'round';
    canvas.stroke();

    canvas.beginPath();
    canvas.arc(
      CENTER_X + this.bubbleX,
      CENTER_Y + this.bubbleY,
      BUBBLE_RADIUS * 0.9, // 稍小于原圆半径
      Math.PI * 1.12, // 起始角度
      Math.PI * 1.5, // 结束角度
      false // 顺时针绘制
    );
    canvas.strokeStyle = 'white';
    canvas.lineWidth = 2;
    canvas.lineCap = 'round';
    canvas.stroke();
  }

  private getOrigin(data: number) {
    let absData = Math.abs(data)
    if (absData <= 90) {
      return data
    }
    return (180 - absData) * Math.sign(data)
  }
}