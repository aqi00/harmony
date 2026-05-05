import { fileIo } from '@kit.CoreFileKit';

const TAG = 'FileCapturer';
const SEND_SIZE: number = 1280;

/**
 * File collector tool
 */
export default class FileCapturer {
  /**
   * Whether the audio is being written
   */
  private mIsWriting: boolean = false;

  /**
   * File Path
   */
  private mFilePath: string = '';

  /**
   * Open File Object
   */
  private mFile: fileIo.File | null = null;

  /**
   * Indicates whether the file can be read.
   */
  private mIsReadFile: boolean = true;

  /**
   * Audio Data Callback Method
   */
  private mDataCallBack: ((data: ArrayBuffer) => void ) | null = null;

  /**
   * Setting the File Path
   * @param filePath
   */
  public setFilePath(filePath: string) {
    this.mFilePath = filePath;
  }

  async init(dataCallBack: (data: ArrayBuffer) => void): Promise<void> {
    if (null != this.mDataCallBack) {
      return;
    }
    this.mDataCallBack = dataCallBack;
    try {
      if (!fileIo.accessSync(this.mFilePath)) {
        return
      }
    } catch (error) {
      console.error("fileIo.accessSync error: " + JSON.stringify(error));
    }
    console.error(TAG, "init start ");
  }

  async start(): Promise<void> {
    try {
      if (this.mIsWriting || null == this.mDataCallBack) {
        return;
      }
      this.mIsWriting = true;
      this.mIsReadFile = true;
      this.mFile = fileIo.openSync(this.mFilePath, fileIo.OpenMode.READ_ONLY);
      let buf: ArrayBuffer = new ArrayBuffer(SEND_SIZE);
      let offset: number = 0;
      while (SEND_SIZE == fileIo.readSync(this.mFile.fd, buf, {
        offset: offset
      }) && this.mIsReadFile) {
        this.mDataCallBack(buf);
        await sleep(40);
        offset = offset + SEND_SIZE;
      }
    } catch (e) {
      console.error(TAG, "read file error " + e);
    } finally {
      if (null != this.mFile) {
        fileIo.closeSync(this.mFile);
      }
      this.mIsWriting = false;
    }
  }

  stop() {
    if (null == this.mDataCallBack) {
      return;
    }
    try {
      this.mIsReadFile = false;
    } catch (e) {
      console.error(TAG, "read file error " + e);
    }
  }

  release() {
    if (null == this.mDataCallBack) {
      return;
    }
    try {
      this.mDataCallBack = null;
      this.mIsReadFile = false;
    } catch (e) {
      console.error(TAG, "read file error " + e);
    }
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise<void>(resolve => setTimeout(resolve, ms));
}