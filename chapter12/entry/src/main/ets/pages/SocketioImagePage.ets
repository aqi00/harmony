import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { buffer } from '@kit.ArkTS';
import { util } from '@kit.ArkTS';
import { client_socket } from '@ohos/socketio';
import { ImagePart } from '../entity/ImagePart';
import { Constants } from '../constant/Constants';

@Entry
@Component
struct SocketioImagePage {
  @State imagePath: string = ''; // 图片路径
  @State result: string = '结果在这里';
  private client: client_socket = new client_socket(); // socketio的客户端对象

  aboutToAppear() {
    this.client.set_open_listener(() => {
      console.info('set_open_listener')
      this.result = '已连上服务器'
    })
    this.client.set_fail_listener(() => {
      console.info('set_fail_listener')
      this.result = '连接服务器失败'
    })
    this.client.set_close_listener(() => {
      console.info('set_close_listener')
    })
    this.client.set_reconnecting_listener(() => {
      console.info('set_reconnecting_listener')
    });
    this.client.set_reconnect_listener(() => {
      console.info('set_reconnect_listener')
      this.result = '尝试连接服务器……'
    });
    this.client.set_socket_open_listener((nsp: string) => {
      console.info('set_socket_open_listener: '+nsp)
    });
    this.client.set_socket_close_listener((nsp: string) => {
      console.info('set_socket_open_listener: '+nsp)
    });
    this.client.connect(Constants.SOCKET_SIMPLE_URL) // socket.io服务端地址
    // 注意：未改动的socketio只认new message，这里用的socketio是改动了的
    this.client.on('receive_pic', (data: string) => {
      console.info('receive_message: '+data)
      this.receiveImage(data) // 接收图像
    })
  }

  aboutToDisappear() {
    this.client.off('receive_pic') // 取消接收图片消息的监听
    this.client.close();
    //this.client.socket_close(); // 注意：这里不可调用socket_close，否则app会崩溃
    this.client.clear_socket_listeners();
  }

  // 50*1024时，socketio发送异常
  private blockSize = 45*1024; // 每段的数据包大小
  private lastFile = ''; // 上次的文件名
  private receiveCount = 0; // 接收包的数量
  @State pixelMap: PixelMap | null = null; // 收到的图像数据
  private resultUint8: Uint8Array | null = null; // 整体结果的字节数组

  // 接收图像
  receiveImage(data: string) {
    let part = JSON.parse(data) as ImagePart
    if (part.name != this.lastFile) { // 与上次文件名不同，表示开始接收新文件
      this.lastFile = part.name;
      this.receiveCount = 0;
      this.resultUint8 = new Uint8Array(part.length)
    }
    console.info('receive_pic, seq: '+part.seq+', length: '+part.length+', block: '+part.seq*this.blockSize)
    this.receiveCount++;
    // 把接收到的图片数据通过BASE64解码为字节数组
    let helper = new util.Base64Helper();
    let temp = helper.decodeSync(part.data, util.Type.MIME).buffer as ArrayBuffer;
    this.resultUint8?.set(new Uint8Array(temp), part.seq*this.blockSize)
    // 所有数据包都接收完毕
    if (this.receiveCount >= Math.floor(part.length/this.blockSize)+1) {
      this.result = '收到服务端消息：' + part.name
      let totalBuffer = this.resultUint8?.buffer as ArrayBuffer
      // 从字节数组中解码得到像素图对象
      let imageSource = image.createImageSource(totalBuffer);
      let opts: image.DecodingOptions = { editable: true };
      imageSource.createPixelMap(opts).then((pixelMap) => {
        this.pixelMap = pixelMap
        console.info('pixelMap size: '+pixelMap.getPixelBytesNumber())
      }).catch((err: BusinessError) => {
        console.error('createPixelMap error message: ' + err.message + ', error code: ' + err.code);
      })
    }
  }

  // 发送图片
  sendImage() {
    let fileName = this.imagePath.toString().split('/').pop() as string
    let suffix = (fileName.split('.').pop() as string).toLowerCase()
    let fileFormat = suffix=='png' ? 'image/png' : 'image/jpeg'
    let file = fileIo.openSync(this.imagePath, fileIo.OpenMode.READ_ONLY);
    console.info(`fileName: ${fileName}, format:${fileFormat}, fileFd: ${file.fd}`);
    let imageSource = image.createImageSource(file.fd);
    imageSource.createPixelMap().then((pixelMap) => {
      // 转换成base64
      let imagePackerApi: image.ImagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 100 };
      imagePackerApi.packToData(pixelMap, packOpts).then((data: ArrayBuffer) => {
        let buf: buffer.Buffer = buffer.from(data);
        let count = Math.floor(buf.length/this.blockSize) + 1;
        console.info(`sendImage length=${buf.length}, count=${count}`);
        // 下面把图片数据经过BASE64编码后发给SocketIO服务器
        for (let i=0; i<count; i++) {
          console.info('sendImage i='+i);
          let encodeData = '';
          if (i == count-1) { // 是最后一段图像数据
            let remain = buf.length % this.blockSize;
            let temp = buffer.alloc(remain);
            buf.copy(temp, 0, i*this.blockSize, i*this.blockSize+remain)
            encodeData = temp.toString('base64');
          } else { // 不是最后一段图像数据
            let temp = buffer.alloc(this.blockSize);
            buf.copy(temp, 0, i*this.blockSize, (i+1)*this.blockSize)
            encodeData = temp.toString('base64');
          }
          // 往SocketIO服务器发送本段的图片数据
          let part: ImagePart = {seq:i, name:fileName, data:encodeData, length:buf.length}
          let data = JSON.stringify(part) // 图片数据转为JSON字符串
          console.info('i='+i+', size='+encodeData.length+', '+data);
          // 怀疑是socketio限制了数据大小，限制了MAX_BUF_SIZE大小
          this.client.emit('send_pic', data); // 发送图像数据
        }
      }).catch((err: BusinessError) => {
        console.error('packing failed with err: ' + JSON.stringify(err));
      });
    }).catch((err: BusinessError) => {
      console.error('createPixelMap failed with err: ' + JSON.stringify(err));
    });
  }

  // 选择相册图片
  choosePhoto() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 5;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      this.imagePath = photoSelectResult.photoUris[0]
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  build() {
    Column() {
      Button('请选择图片').width('100%').fontSize(18)
        .onClick(() => {
          this.choosePhoto() // 选择相册图片
        })
      Image(this.imagePath).height(200).objectFit(ImageFit.Contain)
      Button('发送图片消息').width('100%').fontSize(18)
        .onClick(() => {
          this.sendImage() // 发送图片消息
        })
      Text(this.result).width('100%').fontSize(18).padding(5)
      Image(this.pixelMap).height(200).objectFit(ImageFit.Contain)
    }
    .width('100%')
  }
}