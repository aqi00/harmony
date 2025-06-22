import { mindSporeLite } from '@kit.MindSporeLiteKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct ImageClassifyPage {
  context = this.getUIContext().getHostContext() as common.Context;
  private resMgr = this.context.resourceManager; // 资源管理器
  @State imagePath: string = ''; // 待推理的图片路径
  @State result: string = '推理结果在这里'; // 推理结果
  @State labelsNameArray: string[] = []; // 标签名称数组
  private modelName: string = 'mobilenetv2.ms'; // 模型文件

  aboutToAppear() {
    // 从指定文件加载分类标签的名称数组
    let uint8Array = this.resMgr.getRawFileContentSync('image_label.txt');
    const decoder = util.TextDecoder.create('utf-8');
    const str = decoder.decodeToString(uint8Array);
    this.labelsNameArray = str.split('\n')
  }

  // 选择相册图片
  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1 // 可选择的文件最大数量
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      this.imagePath = photoSelectResult.photoUris[0] // 待推理的图片路径
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  // 开始模型推理
  async modelPredict(modelBuffer: ArrayBuffer, inputsBuffer: ArrayBuffer[]): Promise<mindSporeLite.MSTensor[]> {
    // 1、从内存加载模型
    let msLiteModel = await mindSporeLite.loadModelFromBuffer(modelBuffer);
    // 2、设置输入数据
    let modelInputs: mindSporeLite.MSTensor[] = msLiteModel.getInputs();
    console.info('MS_LITE_LOG: inputsBuffer.length='+inputsBuffer.length);
    for (let i = 0; i < inputsBuffer.length; i++) {
      let inputBuffer = inputsBuffer[i];
      if (inputBuffer != null) {
        modelInputs[i].setData(inputBuffer as ArrayBuffer);
      }
    }
    // 3、执行推理并返回推理结果
    console.info('=========MS_LITE_LOG: MS_LITE predict start=====');
    return await msLiteModel.predict(modelInputs);
  }

  // 根据模型推理图像分类
  doInfer(buffer: ArrayBufferLike) {
    let inputs: ArrayBuffer[] = [buffer];
    let max: number = 0, maxIndex: number = 0;
    let maxArray: number[] = [], maxIndexArray: number[] = [];
    this.resMgr.getRawFileContent(this.modelName).then(modelBuffer => {
      // 开始模型推理
      this.modelPredict(modelBuffer.buffer.slice(0), inputs).then(outputs => {
        console.info('=========MS_LITE_LOG: MS_LITE predict success=====');
        // 结果打印
        for (let i = 0; i < outputs.length; i++) {
          let out = new Float32Array(outputs[i].getData());
          // 取分类占比的最大值
          let newArray = out.filter(value => value !== max)
          for (let n = 0; n < 5; n++) {
            max = out[0];
            maxIndex = 0;
            for (let m = 0; m < newArray.length; m++) {
              if (newArray[m] > max) {
                max = newArray[m];
                maxIndex = m;
              }
            }
            maxArray.push(Math.round(max * 10000))
            maxIndexArray.push(maxIndex)
            // filter函数，数组过滤函数
            newArray = newArray.filter(value => value !== max)
          }
          console.info('MS_LITE_LOG: max:' + maxArray);
          console.info('MS_LITE_LOG: maxIndex:' + maxIndexArray);
          this.result = ''
          for (let n = 0; n < maxArray.length; n++) {
            let index = maxIndexArray[n]
            let ratio = maxArray[n]/100 + '%'
            this.result = `${this.result}${this.labelsNameArray[index]} : ${ratio}\n`
          }
        }
        console.info('=========MS_LITE_LOG END=========');
      })
    })
  }

  // 推理图像分类
  pretreatmentImage() {
    let modelHeight = 224, modelWidth = 224;
    // 打开文件得到fd
    let file = fileIo.openSync(this.imagePath, fileIo.OpenMode.READ_ONLY);
    console.info('MS_LITE_LOG: file fd: ' + file.fd);
    // 通过PixelMap预处理
    let imageSource = image.createImageSource(file.fd);
    imageSource.createPixelMap().then((pixelMap) => {
      let size = pixelMap.getImageInfoSync().size;
      console.info(`MS_LITE_LOG: width=${size.width}, height=${size.height}`);
      // 根据模型输入的尺寸，将图片裁剪为对应大小
      pixelMap.scaleSync(256.0 /size.width, 256.0 / size.height);
      pixelMap.cropSync({ x: 16, y: 16, size: { height: modelHeight, width: modelWidth } })
      // 需要创建的像素缓存大小
      let readBuffer = new ArrayBuffer(modelHeight * modelWidth * 4);
      pixelMap.readPixelsToBufferSync(readBuffer)
      console.info('MS_LITE_LOG: Succeeded in reading image pixel data, buffer: ' + readBuffer.byteLength);
      // 将读到的像素缓存转换成float32格式，并进行标准化处理
      let imgArr = new Uint8Array(readBuffer.slice(0, modelHeight * modelWidth * 4));
      console.info('MS_LITE_LOG: imgArr length: ' + imgArr.length);
      let means = [0.485, 0.456, 0.406];
      let stds = [0.229, 0.224, 0.225];
      let float32View = new Float32Array(modelHeight * modelWidth * 3);
      let index = 0;
      for (let i = 0; i < imgArr.length; i++) {
        if ((i + 1) % 4 == 0) {
          float32View[index] = (imgArr[i - 3] / 255.0 - means[0]) / stds[0]; // B
          float32View[index+1] = (imgArr[i - 2] / 255.0 - means[1]) / stds[1]; // G
          float32View[index+2] = (imgArr[i - 1] / 255.0 - means[2]) / stds[2]; // R
          index += 3;
        }
      }
      this.doInfer(float32View.buffer) // 根据模型推理图像分类
    }).catch((err: BusinessError) => {
      console.error('createPixelMap failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('到相册选择图片').width('100%').fontSize(18)
        .onClick(() => {
          this.choosePhoto() // 选择相册图片
        })
      Image(this.imagePath).width('100%').height(360)
      Button('推理图像分类').width('100%').fontSize(18)
        .onClick(() => {
          this.pretreatmentImage() // 推理图像分类
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
    }
    .width('100%').height('100%')
  }
}