/*
 * napi_init.cpp
 *
 * DJVU 阅读器 NAPI 桥（鸿蒙 NDK 规范）
 * 改写自 Android: jni/vudroid/DjvuDroidBridge.cpp
 * 把 JNI 入口改造为 NAPI，句柄以 bigint 传递；
 * DjvuContext 的 Java 消息循环线程搬进 native（std::thread + condition_variable）。
 */

#include <napi/native_api.h>

// sysroot 未提供 native_node_api.h，本地补齐常用宏
#ifdef __cplusplus
#define EXTERN_C_START extern "C" {
#define EXTERN_C_END }
#else
#define EXTERN_C_START
#define EXTERN_C_END
#endif

#define DECLARE_NAPI_FUNCTION(name, func) \
    { name, nullptr, func, nullptr, nullptr, nullptr, napi_default, nullptr }

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <string>
#include <thread>
#include <chrono>

#include "DjvuDroidTrace.h"
#include "ddjvuapi.h"

// ==================== DjvuContext 状态：消息循环 + 同步等待 DOCINFO ====================
// 取代原 DjvuContext.java 的 Thread 循环 + Semaphore/handleDocInfo 回调机制。
struct DjvuContextState {
    ddjvu_context_t *ctx = nullptr;
    std::atomic<bool> stop{false};
    std::mutex mtx;
    std::condition_variable cv;
    bool docInfoReceived{false};
    std::string lastError;
    std::thread msgThread;

    DjvuContextState() {
        ctx = ddjvu_context_create(DJVU_DROID);
        DEBUG_WRITE("Creating context");
        msgThread = std::thread([this]() { runMessageLoop(); });
    }

    ~DjvuContextState() {
        stop.store(true);
        if (msgThread.joinable()) {
            msgThread.join();
        }
        if (ctx) {
            ddjvu_context_release(ctx);
            ctx = nullptr;
        }
    }

    // 消息循环：peek 处理 ERROR/INFO/DOCINFO，sleep 50ms，由 stop 退出。
    void runMessageLoop() {
        while (!stop.load()) {
            const ddjvu_message_t *msg;
            while ((msg = ddjvu_message_peek(ctx))) {
                switch (msg->m_any.tag) {
                    case DDJVU_ERROR: {
                        const char *emsg =
                            (msg->m_error.message) ? msg->m_error.message : "Djvu decoding error";
                        DEBUG_PRINT("ddjvu error: %s", emsg);
                        std::lock_guard<std::mutex> lk(mtx);
                        lastError = emsg;
                        docInfoReceived = true;
                        cv.notify_all();
                        break;
                    }
                    case DDJVU_DOCINFO: {
                        DEBUG_WRITE("DOCINFO received");
                        std::lock_guard<std::mutex> lk(mtx);
                        docInfoReceived = true;
                        cv.notify_all();
                        break;
                    }
                    case DDJVU_INFO:
                    default:
                        break;
                }
                ddjvu_message_pop(ctx);
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(50));
        }
        // 退出前排空残余消息
        const ddjvu_message_t *msg;
        while ((msg = ddjvu_message_peek(ctx))) {
            ddjvu_message_pop(ctx);
        }
    }

    // 阻塞等待 DOCINFO（或 ERROR），返回是否超时；errOut 收集错误。
    bool waitForDocInfo(std::string &errOut) {
        std::unique_lock<std::mutex> lk(mtx);
        bool ok = cv.wait_for(lk, std::chrono::seconds(30),
                              [this]() { return docInfoReceived; });
        errOut = lastError;
        docInfoReceived = false;
        lastError.clear();
        return ok;
    }
};

// ==================== 辅助函数 ====================

static uint64_t AsUint64(napi_env env, napi_value val) {
    bool lossless = false;
    uint64_t out = 0;
    napi_get_value_bigint_uint64(env, val, &out, &lossless);
    return out;
}

static napi_value MakeBigint(napi_env env, uint64_t v) {
    napi_value result;
    napi_create_bigint_uint64(env, v, &result);
    return result;
}

static std::string GetString(napi_env env, napi_value val) {
    size_t len = 0;
    napi_get_value_string_utf8(env, val, nullptr, 0, &len);
    std::string s(len, '\0');
    napi_get_value_string_utf8(env, val, &s[0], len + 1, &len);
    return s;
}

// ==================== NAPI 实现 ====================

// djvuCreate(): 创建上下文并启动消息循环线程，返回 bigint(DjvuContextState*)。
static napi_value DjvuCreate(napi_env env, napi_callback_info info) {
    auto *state = new DjvuContextState();
    return MakeBigint(env, reinterpret_cast<uint64_t>(state));
}

// djvuContextFree(ctx): 停止线程并释放上下文。
static napi_value DjvuContextFree(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *state = reinterpret_cast<DjvuContextState *>(AsUint64(env, args[0]));
    if (state) {
        delete state;
    }
    return nullptr;
}

// djvuOpen(ctx, path): 打开文档并阻塞至 DOCINFO，返回 bigint(ddjvu_document_t*)。
static napi_value DjvuOpen(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *state = reinterpret_cast<DjvuContextState *>(AsUint64(env, args[0]));
    if (!state || !state->ctx) {
        napi_throw_error(env, "DJVU_ERROR", "Invalid context");
        return MakeBigint(env, 0);
    }
    std::string path = GetString(env, args[1]);
    DEBUG_PRINT("Opening document: %s", path.c_str());
    ddjvu_document_t *doc =
        ddjvu_document_create_by_filename(state->ctx, path.c_str(), FALSE);
    std::string err;
    state->waitForDocInfo(err);
    if (!err.empty()) {
        napi_throw_error(env, "DJVU_ERROR", err.c_str());
        return MakeBigint(env, 0);
    }
    return MakeBigint(env, reinterpret_cast<uint64_t>(doc));
}

// djvuGetPageCount(doc): 返回文档总页数。
static napi_value DjvuGetPageCount(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *doc = reinterpret_cast<ddjvu_document_t *>(AsUint64(env, args[0]));
    int count = doc ? ddjvu_document_get_pagenum(doc) : 0;
    napi_value result;
    napi_create_int32(env, count, &result);
    return result;
}

// djvuGetPage(doc, pageNo): 返回 bigint(ddjvu_page_t*)。
static napi_value DjvuGetPage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *doc = reinterpret_cast<ddjvu_document_t *>(AsUint64(env, args[0]));
    int pageNo = 0;
    napi_get_value_int32(env, args[1], &pageNo);
    DEBUG_PRINT("getPage num: %d", pageNo);
    ddjvu_page_t *page = doc ? ddjvu_page_create_by_pageno(doc, pageNo) : nullptr;
    return MakeBigint(env, reinterpret_cast<uint64_t>(page));
}

// djvuDocumentFree(doc): 释放文档。
static napi_value DjvuDocumentFree(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *doc = reinterpret_cast<ddjvu_document_t *>(AsUint64(env, args[0]));
    if (doc) {
        ddjvu_document_release(doc);
    }
    return nullptr;
}

// djvuPageGetWidth(page): 返回页宽。
static napi_value DjvuPageGetWidth(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *page = reinterpret_cast<ddjvu_page_t *>(AsUint64(env, args[0]));
    int w = page ? ddjvu_page_get_width(page) : 0;
    napi_value result;
    napi_create_int32(env, w, &result);
    return result;
}

// djvuPageGetHeight(page): 返回页高。
static napi_value DjvuPageGetHeight(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *page = reinterpret_cast<ddjvu_page_t *>(AsUint64(env, args[0]));
    int h = page ? ddjvu_page_get_height(page) : 0;
    napi_value result;
    napi_create_int32(env, h, &result);
    return result;
}

// djvuPageIsDecodingDone(page): 返回是否解码完成。
static napi_value DjvuPageIsDecodingDone(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *page = reinterpret_cast<ddjvu_page_t *>(AsUint64(env, args[0]));
    bool done = page ? ddjvu_page_decoding_done(page) : true;
    napi_value result;
    napi_get_boolean(env, done, &result);
    return result;
}

// djvuRenderPage(page, w, h, sliceX, sliceY, sliceW, sliceH, buf):
//   渲染到 buf(Uint8Array, 长度 w*h*4)，原地 0x00RRGGBB → 0xFFBBGGRR 以对齐 RGBA_8888。
static napi_value DjvuRenderPage(napi_env env, napi_callback_info info) {
    size_t argc = 8;
    napi_value args[8];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *page = reinterpret_cast<ddjvu_page_t *>(AsUint64(env, args[0]));
    int targetWidth = 0, targetHeight = 0;
    napi_get_value_int32(env, args[1], &targetWidth);
    napi_get_value_int32(env, args[2], &targetHeight);
    double sliceX = 0, sliceY = 0, sliceW = 1, sliceH = 1;
    napi_get_value_double(env, args[3], &sliceX);
    napi_get_value_double(env, args[4], &sliceY);
    napi_get_value_double(env, args[5], &sliceW);
    napi_get_value_double(env, args[6], &sliceH);

    void *data = nullptr;
    size_t length = 0;
    napi_get_typedarray_info(env, args[7], nullptr, &length, &data, nullptr, nullptr);

    if (!page || !data || targetWidth <= 0 || targetHeight <= 0 || sliceW <= 0 || sliceH <= 0) {
        napi_value r;
        napi_get_boolean(env, false, &r);
        return r;
    }

    DEBUG_WRITE("Rendering page");
    ddjvu_rect_t pageRect;
    pageRect.x = 0;
    pageRect.y = 0;
    pageRect.w = (int)(targetWidth / sliceW);
    pageRect.h = (int)(targetHeight / sliceH);
    ddjvu_rect_t targetRect;
    targetRect.x = (int)(sliceX * targetWidth / sliceW);
    targetRect.y = (int)(sliceY * targetHeight / sliceH);
    targetRect.w = targetWidth;
    targetRect.h = targetHeight;

    unsigned int masks[] = {0xFF0000, 0x00FF00, 0x0000FF};
    ddjvu_format_t *fmt = ddjvu_format_create(DDJVU_FORMAT_RGBMASK32, 3, masks);
    ddjvu_format_set_row_order(fmt, TRUE);
    ddjvu_format_set_y_direction(fmt, TRUE);

    int ok = ddjvu_page_render(page, DDJVU_RENDER_COLOR, &pageRect, &targetRect, fmt,
                               targetWidth * 4, (char *)data);
    ddjvu_format_release(fmt);

    // 原地转换：ddjvu 输出 0x00RRGGBB，转为内存 [R,G,B,0xFF]（RGBA_8888）。
    unsigned int *px = (unsigned int *)data;
    int count = targetWidth * targetHeight;
    for (int i = 0; i < count; i++) {
        unsigned int p = px[i];
        px[i] = 0xFF000000u | ((p & 0xFF0000u) >> 16) | (p & 0xFF00u) | ((p & 0xFFu) << 16);
    }

    napi_value result;
    napi_get_boolean(env, ok != 0, &result);
    return result;
}

// djvuPageFree(page): 释放页。
static napi_value DjvuPageFree(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto *page = reinterpret_cast<ddjvu_page_t *>(AsUint64(env, args[0]));
    if (page) {
        ddjvu_page_release(page);
    }
    return nullptr;
}

// ==================== 模块注册 ====================

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        DECLARE_NAPI_FUNCTION("djvuCreate", DjvuCreate),
        DECLARE_NAPI_FUNCTION("djvuContextFree", DjvuContextFree),
        DECLARE_NAPI_FUNCTION("djvuOpen", DjvuOpen),
        DECLARE_NAPI_FUNCTION("djvuGetPageCount", DjvuGetPageCount),
        DECLARE_NAPI_FUNCTION("djvuGetPage", DjvuGetPage),
        DECLARE_NAPI_FUNCTION("djvuDocumentFree", DjvuDocumentFree),
        DECLARE_NAPI_FUNCTION("djvuPageGetWidth", DjvuPageGetWidth),
        DECLARE_NAPI_FUNCTION("djvuPageGetHeight", DjvuPageGetHeight),
        DECLARE_NAPI_FUNCTION("djvuPageIsDecodingDone", DjvuPageIsDecodingDone),
        DECLARE_NAPI_FUNCTION("djvuRenderPage", DjvuRenderPage),
        DECLARE_NAPI_FUNCTION("djvuPageFree", DjvuPageFree),
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module djvuModule = {
    .nm_version = 1,
    .nm_flags = 1,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "djvu",
    .nm_priv = nullptr,
    .reserved = {},
};

extern "C" __attribute__((constructor)) void RegisterDjvuModule(void) {
    napi_module_register(&djvuModule);
}
