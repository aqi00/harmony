/**
 * 汉字简繁转换
 * 
 * @auth superbiger(superbiger@qq.com)
 */
import { PinyinResource } from "./PinyinResource.js"
import LogUtil from './LogUtil';

var CHINESE_REGEX = /^[\u4e00-\u9fa5]+$/;
var CHINESE_MAP = PinyinResource.getChineseResource();

export class ChineseHelper {
    /**
     * 将单个繁体字转换为简体字
     * @param {string/char} c
     */
    static _convertCharToSimplifiedChinese(c) {
        LogUtil.info(`_convertCharToSimplifiedChinese, c: ${c}`);
        var simplifiedChinese = CHINESE_MAP[c];
        if(typeof(simplifiedChinese) == "undefined") {
            return c;
        }
        return simplifiedChinese;
    }

    /**
     * 将单个简体字转换为繁体字
     * @param {string/char} c
     */
    static _convertCharToTraditionalChinese(c) {
        LogUtil.info(`_convertCharToTraditionalChinese, c: ${c}`);
        for(var key in CHINESE_MAP) {
            if(CHINESE_MAP[key] == c) {
                return key;
            }
        }
        return c;
    }

    /**
     * 将繁体转化为简体
     * @param {string} str 
     */
    static convertToSimplifiedChinese(str) {
        LogUtil.info(`convertToSimplifiedChinese, str: ${str}`);
        var result = '';
        for(var i=0; i < str.length; i++) {
            var c = str.charAt(i);
            result += this._convertCharToSimplifiedChinese(c);
        }
        return result;
    }

    /**
     * 将简体转化为繁体
     * @param {string} str 
     */
    static convertToTraditionalChinese(str) {
        LogUtil.info(`convertToTraditionalChinese, str: ${str}`);
        var result = '';
        for(var i=0; i < str.length; i++) {
            var c = str.charAt(i);
            result += this._convertCharToTraditionalChinese(c);
        }
        return result;
    }

    /**
     * 判断是否为繁体字
     * @param {string/char} c 
     */
    static isTraditionalChinese(c) {
        LogUtil.info(`isTraditionalChinese, c: ${c}`);
        var val = CHINESE_MAP[c];
        return  typeof(val) != 'undefined'
    }

    /**
     * 判断是否为汉字
     * @param {string/char} c 
     */
    static isChinese(c) {
        LogUtil.info(`isChinese, c: ${c}`);
        return '〇' == c || CHINESE_REGEX.test(c)
    }

    /**
     * 是否包含汉字
     * @param {string} str 
     */
    static containsChinese(str) {
        LogUtil.info(`containsChinese, str: ${str}`);
        for(var i=0; i < str.length; i++) {
            if(this.isChinese(str.charAt(i))){
                return true;
            }
        }
        return false;
    }

    static addChineseDictResource(res) {
        CHINESE_MAP = Object.assign(res, CHINESE_MAP);
    }
}