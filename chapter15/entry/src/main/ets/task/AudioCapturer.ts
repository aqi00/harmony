'use strict';
/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import {audio} from '@kit.AudioKit';
import { ICapturerInterface } from './ICapturerInterface'

const TAG = 'AudioCapturer';

/**
 * 音频采集器工具
 */
export default class AudioCapturer implements ICapturerInterface {
  /**
   * 采集器对象
   */
  private mAudioCapturer = null;

  /**
   * 音频数据回调方法
   */
  private mDataCallBack: (data: ArrayBuffer) => void = null;

  /**
   * 是否可以获取录音数据
   */
  private mCanWrite: boolean = true;

  /**
   * 音频流信息
   */
  private audioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }

  /**
   * 音频采集器信息
   */
  private audioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  }

  /**
   * 音频采集器选项信息
   */
  private audioCapturerOptions = {
    streamInfo: this.audioStreamInfo,
    capturerInfo: this.audioCapturerInfo
  }

  /**
   *  初始化
   * @param audioListener 音频回调
   */
  public async init(dataCallBack: (data: ArrayBuffer) => void) {
    if (null != this.mAudioCapturer) {
      console.error(TAG, 'AudioCapturerUtil already init');
      return;
    }
    this.mDataCallBack = dataCallBack;
    this.mAudioCapturer = await audio.createAudioCapturer(this.audioCapturerOptions).catch(error => {
      console.error(TAG, `AudioCapturerUtil init createAudioCapturer failed, code is ${error.code}, message is ${error.message}`);
    });
  }

  /**
   * 录音开始
   */
  public async start(callback: () => void) {
    console.error(TAG, `AudioCapturerUtil start`);
    let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
    if (stateGroup.indexOf(this.mAudioCapturer.state) === -1) {
      console.error(TAG, `AudioCapturerUtil start failed`);
      return;
    }
    this.mCanWrite = true;
    await this.mAudioCapturer.start();
    while (this.mCanWrite) {
      let bufferSize = await this.mAudioCapturer.getBufferSize();
      let buffer = await this.mAudioCapturer.read(bufferSize, true);
      this.mDataCallBack(buffer)
    }
  }

  /**
   * 停止采集
   */
  public async stop() {
    if (this.mAudioCapturer.state !== audio.AudioState.STATE_RUNNING && this.mAudioCapturer.state !== audio.AudioState.STATE_PAUSED) {
      console.error(TAG, `AudioCapturerUtil stop Capturer is not running or paused`);
      return;
    }
    this.mCanWrite = false;
    await this.mAudioCapturer.stop();
    if (this.mAudioCapturer.state === audio.AudioState.STATE_STOPPED) {
      console.info(TAG, `AudioCapturerUtil Capturer stopped`);
    } else {
      console.error(TAG, `Capturer stop failed`);
    }
  }

  /**
   * 销毁实例
   */
  public async release() {
    if (this.mAudioCapturer.state === audio.AudioState.STATE_RELEASED || this.mAudioCapturer.state === audio.AudioState.STATE_NEW) {
      console.error(TAG, `Capturer already released`);
      return;
    }
    await this.mAudioCapturer.release();
    this.mAudioCapturer = null;
    if (this.mAudioCapturer.state == audio.AudioState.STATE_RELEASED) {
      console.info(TAG, `Capturer released`);
    } else {
      console.error(TAG, `Capturer release failed`);
    }
  }
}
