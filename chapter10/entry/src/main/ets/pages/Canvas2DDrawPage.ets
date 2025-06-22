@Entry
@Component
struct Canvas2DDrawPage {
  context = this.getUIContext();
  @State isSolid: boolean = true; // 是否实心
  private canvas: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private canvasWidth = 0; // 画布宽度
  private canvasHeight = 0; // 画布高度

  // 在画布上绘图
  drawCanvas() {
    let rightEdge = 900
    if (this.canvasWidth != 0) {
      rightEdge = this.canvasWidth-100/this.context.vp2px(1)
    }
    // 清空画布区域
    this.canvas.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
    // 下面开始绘图
    this.canvas.strokeStyle = '#0000ff' // 线条颜色
    this.canvas.lineWidth = this.context.vp2px(1) // 线条宽度
    this.canvas.beginPath() // 创建新的绘制路径
    this.canvas.moveTo(100/this.context.vp2px(1), 50/this.context.vp2px(1))
    this.canvas.lineTo(rightEdge, 50/this.context.vp2px(1))
    this.canvas.stroke() // 描绘路径上的线条
    this.canvas.beginPath() // 创建新的绘制路径
    if (this.isSolid) { // 实心
      // 先调用arc，再调用fill，才能绘制实心圆
      this.canvas.arc(200/this.context.vp2px(1), 200/this.context.vp2px(1),
        100/this.context.vp2px(1), 0, 6.28)
      this.canvas.fill() // 填充路径内部区域
    } else { // 空心
      // 先调用arc，再调用stroke，才能绘制空心圆
      this.canvas.arc(200/this.context.vp2px(1), 200/this.context.vp2px(1),
        100/this.context.vp2px(1), 0, 6.28)
      this.canvas.stroke() // 描绘路径上的线条
    }
    if (this.isSolid) { // 实心。调用fillRect绘制实心方块
      // fillRect会立即绘制实心矩形，rect要等调用fill之后才会绘制实心矩形
      this.canvas.fillRect(400/this.context.vp2px(1), 100/this.context.vp2px(1),
        rightEdge-400/this.context.vp2px(1), (300-100)/this.context.vp2px(1))
    } else { // 空心。调用strokeRect绘制空心方框
      // strokeRect会立即绘制矩形边框，rect要等调用stroke之后才会绘制矩形边框
      this.canvas.strokeRect(400/this.context.vp2px(1), 100/this.context.vp2px(1),
        rightEdge-400/this.context.vp2px(1), (300-100)/this.context.vp2px(1))
    }
  }

  build() {
    Column() {
      Row() {
        Text('是否实心：').fontSize(18)
        Checkbox().select($$this.isSolid)
          .onChange((value: boolean) => {
            this.drawCanvas() // 在画布上绘图
          })
      }
      Canvas(this.canvas).width('100%').height('100%')
        .onAppear(() => {
          console.info('onAppear')
        })
          // 组件尺寸发生变化时触发
        .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          console.info(`onSizeChange, oldValue is ${JSON.stringify(oldValue)} value is ${JSON.stringify(newValue)}`)
        })
        .onReady(() => {
          console.info('onReady')
        })
        // 组件尺寸或者组件位置发生变化时触发
        .onAreaChange((oldValue: Area, newValue: Area) => {
          console.info(`onAreaChange, oldValue is ${JSON.stringify(oldValue)} value is ${JSON.stringify(newValue)}`)
          this.canvasWidth = Number(newValue.width)
          this.canvasHeight = Number(newValue.height)
          this.drawCanvas() // 在画布上绘图
        })
    }
    .width('100%').height('100%')
  }
}