import { audio } from '@kit.AudioKit';

const TAG = 'AudioCapturer';

/**
 * Audio collector tool
 */
interface GeneratedObjectLiteralInterface_1 {
  samplingRate: audio.AudioSamplingRate;
  channels: audio.AudioChannel;
  sampleFormat: audio.AudioSampleFormat;
  encodingType: audio.AudioEncodingType;
}

interface GeneratedObjectLiteralInterface_2 {
  source: audio.SourceType;
  capturerFlags: number;
}

interface GeneratedObjectLiteralInterface_3 {
  streamInfo: GeneratedObjectLiteralInterface_1;
  capturerInfo: GeneratedObjectLiteralInterface_2;
}

export default class AudioCapturer {
  /**
   * Collector object
   */
  private mAudioCapturer: audio.AudioCapturer | null = null;

  /**
   * Audio Data Callback Method
   */
  private mDataCallBack: ((data: ArrayBuffer) => void) | null = null;

  /**
   * Audio stream information
   */
  private audioStreamInfo: GeneratedObjectLiteralInterface_1 = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }

  /**
   * Audio collector information
   */
  private audioCapturerInfo: GeneratedObjectLiteralInterface_2 = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  }

  /**
   * Audio Collector Option Information
   */
  private audioCapturerOptions: GeneratedObjectLiteralInterface_3 = {
    streamInfo: this.audioStreamInfo,
    capturerInfo: this.audioCapturerInfo
  }

  /**
   *  Initialize
   * @param audioListener
   */
  public async init(dataCallBack: (data: ArrayBuffer) => void) {
    if (null != this.mAudioCapturer) {
      console.error(TAG, 'AudioCapturerUtil already init');
      return;
    }
    this.mDataCallBack = dataCallBack;
    try {
      this.mAudioCapturer = await audio.createAudioCapturer(this.audioCapturerOptions)
    } catch (error) {
      console.error(TAG, `AudioCapturerUtil init createAudioCapturer failed, code is ${error.code}, message is ${error.message}`);
    }
  }

  /**
   * start recording
   */
  public async start() {
    console.error(TAG, `AudioCapturerUtil start`);
    let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
    if (null === this.mAudioCapturer) {
      console.error(TAG, `AudioCapturerUtil have not init`);
      return;
    }
    if (stateGroup.indexOf(this.mAudioCapturer.state) === -1) {
      console.error(TAG, `AudioCapturerUtil start failed`);
      return;
    }
    this.mAudioCapturer.on('readData', this.mDataCallBack);
    await this.mAudioCapturer.start();
  }

  /**
   * stop recording
   */
  public async stop() {
    this.mAudioCapturer?.off('readData');
    if (null === this.mAudioCapturer) {
      console.error(TAG, `AudioCapturerUtil have not init`);
      return;
    }
    if (this.mAudioCapturer.state !== audio.AudioState.STATE_RUNNING && this.mAudioCapturer.state !== audio.AudioState.STATE_PAUSED) {
      console.error(TAG, `AudioCapturerUtil stop Capturer is not running or paused`);
      return;
    }
    await this.mAudioCapturer.stop();
    if (Number(this.mAudioCapturer.state) == audio.AudioState.STATE_STOPPED) {
      console.info(TAG, `AudioCapturerUtil Capturer stopped`);
    } else {
      console.error(TAG, `Capturer stop failed`);
    }
  }

  /**
   * release
   */
  public async release() {
    this.mAudioCapturer?.off('readData');
    if (null === this.mAudioCapturer) {
      console.error(TAG, `AudioCapturerUtil have not init`);
      return;
    }
    if (this.mAudioCapturer.state === audio.AudioState.STATE_RELEASED || this.mAudioCapturer.state === audio.AudioState.STATE_NEW) {
      console.error(TAG, `Capturer already released`);
      return;
    }
    await this.mAudioCapturer.release();
    this.mAudioCapturer = null;
    if (this.mAudioCapturer === null) {
      console.info(TAG, `Capturer released`);
    } else {
      console.error(TAG, `Capturer release failed`);
    }
  }
}