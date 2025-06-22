'use strict';
/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import { ICapturerInterface } from './ICapturerInterface'
import {fileIo} from '@kit.CoreFileKit';
import { Util } from './Util'
import { AsrConstants } from './AsrConstants';


const TAG = 'FileCapturer';

/**
 * 文件采集器工具
 */
export default class FileCapturer implements ICapturerInterface {
  /**
   * 是否在写音频中
   */
  private mIsWriting: boolean = false;

  /**
   * 文件路径
   */
  private mFilePath: string = '';

  /**
   * 打开的文件对象
   */
  private mFile: fileIo.File = null;

  /**
   * 是否可以读取文件
   */
  private mIsReadFile: boolean = true;

  /**
   * 音频数据回调方法
   */
  private mDataCallBack: (data: ArrayBuffer) => void = null;

  /**
   * 设置文件路径
   * @param filePath 文件路径
   */
  public setFilePath(filePath: string) {
    this.mFilePath = filePath;
  }

  async init(dataCallBack: (data: ArrayBuffer) => void) {
    if (null != this.mDataCallBack) {
      return;
    }
    this.mDataCallBack = dataCallBack;
    if (!fileIo.accessSync(this.mFilePath)) {
      return
    }
    console.error(TAG, "init start ");
  }

  async start(callback: () => void) {
    try {
      if (this.mIsWriting || null == this.mDataCallBack) {
        return;
      }
      this.mIsWriting = true;
      this.mIsReadFile = true;
      this.mFile = fileIo.openSync(this.mFilePath, fileIo.OpenMode.READ_WRITE);
      let buf: ArrayBuffer = new ArrayBuffer(AsrConstants.SEND_SIZE);
      let offset: number = 0;
      let count = 0;
      while (AsrConstants.SEND_SIZE == fileIo.readSync(this.mFile.fd, buf, {
        offset: offset
      }) && this.mIsReadFile) {
        this.mDataCallBack(buf);
        ++count;
        //HiAiLog.info(TAG, "write pcm count:" + count);
        //模拟实际情况，读文件比录音机返回流快，所以要等待一段时间
        await Util.countDownLatch(1);
        offset = offset + AsrConstants.SEND_SIZE;
      }
      callback()
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
