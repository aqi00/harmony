'use strict';

/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */


/**
 * Listener回调事件对应的code值
 */
export enum LISTENER_CODE {
  /**
   * 初始化
   */
  METHOD_ON_INIT = 1,

  /**
   * 检测到人声时回调
   */
  METHOD_ON_BEGINNING_OF_SPEECH = 2,

  /**
   * 实时返回音量能量值
   */
  METHOD_ON_RMS_CHANGED = 3,

  /**
   * 用户说话结束
   */
  METHOD_ON_END_OF_SPEECH = 4,

  /**
   * 网络或者识别出错
   */
  METHOD_ON_ERROR = 5,

  /**
   * 当识别场景为听写的时候，触发
   */
  METHOD_ON_PARTIAL_RESULTS = 6,

  /**
   * 识别结果
   */
  METHOD_ON_RESULTS = 7,

  /**
   * 触发语义vad或多模vad
   */
  METHOD_ON_SUB_TEXT = 8,

  /**
   * 当前会话识别结束
   */
  METHOD_ON_END = 9,

  /**
   * 词图更新结束
   */
  METHOD_ON_LEXICON_UPDATED = 10,

  /**
   * 更新参数结束
   */
  METHOD_ON_UPDATE_PARAMS = 11
}

/**
 * 常量类
 */
export class AsrConstants {
  /**
   * VAD前端点时长
   */
  public static readonly ASR_VAD_FRONT_WAIT_MS: string = "vad_front_wait_ms";

  /**
   * VAD后端点时长
   */
  public static readonly ASR_VAD_END_WAIT_MS: string = "vad_end_wait_ms";

  /**
   * ASR超时时长
   */
  public static readonly ASR_TIMEOUT_THRESHOLD_MS: string = "timeout_threshold_ms";

  /**
   * 每次发送的音频大小
   */
  public static readonly SEND_SIZE: number = 1280;
}



