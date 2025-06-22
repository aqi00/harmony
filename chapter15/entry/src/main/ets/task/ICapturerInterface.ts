//'use strict';
/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

/**
 * 采集器接口
 *
 * @author xwx1079711
 * @since 2023-09-08
 */
export interface ICapturerInterface {
  /**
   * 初始化
   * @param dataCallBack 音频数据回调方法
   */
  init(dataCallBack: (data: ArrayBuffer) => void);

  /**
   * 开始
   */
  start(callback: () => void);

  /**
   * 停止
   */
  stop();

  /**
   * 释放
   */
  release();
}