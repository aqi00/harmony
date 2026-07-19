/*
 * The MIT License (MIT)
 * Copyright (c) 2025 Shenzhen Kaihong Digital Industry Development Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 */
import hilog from '@ohos.hilog';

export default class LogUtil {
    static DOMAIN = 0x0000;
    static TAG = 'pinyin4js';

    static debug(message) {
        hilog.debug(LogUtil.DOMAIN, LogUtil.TAG, message);
    }

    static info(message) {
        hilog.info(LogUtil.DOMAIN, LogUtil.TAG, message);
    }

    static log(message) {
        hilog.debug(LogUtil.DOMAIN, LogUtil.TAG, message);
    }

    static warn(message) {
        hilog.warn(LogUtil.DOMAIN, LogUtil.TAG, message);
    }

    static error(message) {
        hilog.error(LogUtil.DOMAIN, LogUtil.TAG, message);
    }
}