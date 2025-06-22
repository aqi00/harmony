'use strict';

/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

/**
 * 工具类
 *
 * @author xwx1079711
 * @since 2023-08-25
 */
export class Util {
  /**
   * 等待器
   * @param count
   */
  public static async countDownLatch(count: number) {
    while (count > 0) {
      await this.sleep(40);
      count--;
    }
  }

  /**
   * 睡眠
   * @param ms 毫秒
   * @returns
   */
  private static sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}