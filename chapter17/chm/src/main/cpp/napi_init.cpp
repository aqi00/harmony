/*
 * NAPI bridge for chmlib (chm_lib.c / lzx.c).
 *
 * 由 Android 侧 chm_jni.cpp 改写：JNI 入口全部替换为 NAPI 导出函数，
 * 句柄以 bigint 传递；文件读写仍走 chmExternalFileStream（fopen/fseeko/fread），
 * 因此 CHM 的块缓存与 LZX 解压逻辑完全保留在原 C 代码里。
 */

#include <napi/native_api.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

#include "chm_lib.h"

#define DECLARE_NAPI_FUNCTION(name, func) \
    { name, nullptr, func, nullptr, nullptr, nullptr, napi_default, nullptr }

namespace {

/** 外部流实现：包装 stdio FILE。 */
struct HarmonyFileStream {
    chmExternalFileStream base;
    FILE *fp;
};

LONGUINT64 streamOpen(chmExternalFileStream *stream) {
    HarmonyFileStream *fs = reinterpret_cast<HarmonyFileStream *>(stream);
    if (!fs->fp) {
        return 0;
    }
    if (fseeko(fs->fp, 0, SEEK_END) != 0) {
        return 0;
    }
    off_t size = ftello(fs->fp);
    fseeko(fs->fp, 0, SEEK_SET);
    return size < 0 ? 0 : static_cast<LONGUINT64>(size);
}

LONGINT64 streamRead(chmExternalFileStream *stream, unsigned char *buf,
                     LONGUINT64 pos, LONGINT64 len) {
    HarmonyFileStream *fs = reinterpret_cast<HarmonyFileStream *>(stream);
    if (!fs->fp || len <= 0) {
        return 0;
    }
    if (fseeko(fs->fp, static_cast<off_t>(pos), SEEK_SET) != 0) {
        return 0;
    }
    size_t got = fread(buf, 1, static_cast<size_t>(len), fs->fp);
    return static_cast<LONGINT64>(got);
}

int streamClose(chmExternalFileStream *stream) {
    HarmonyFileStream *fs = reinterpret_cast<HarmonyFileStream *>(stream);
    if (fs->fp) {
        fclose(fs->fp);
        fs->fp = nullptr;
    }
    free(fs);
    return 0;
}

std::string getStringArg(napi_env env, napi_value value) {
    size_t length = 0;
    if (napi_get_value_string_utf8(env, value, nullptr, 0, &length) != napi_ok) {
        return std::string();
    }
    std::string result(length, '\0');
    napi_get_value_string_utf8(env, value, &result[0], length + 1, &length);
    return result;
}

uint64_t getHandleArg(napi_env env, napi_value value) {
    uint64_t out = 0;
    bool lossless = false;
    napi_get_value_bigint_uint64(env, value, &out, &lossless);
    return out;
}

napi_value makeHandle(napi_env env, uint64_t value) {
    napi_value result = nullptr;
    napi_create_bigint_uint64(env, value, &result);
    return result;
}

/** chmlib 内部路径统一以 '/' 开头，并以 '/' 分隔。 */
std::string normalizeChmPath(const std::string &path) {
    if (path.empty()) {
        return path;
    }
    std::string result = path;
    for (size_t i = 0; i < result.size(); i++) {
        if (result[i] == '\\') {
            result[i] = '/';
        }
    }
    if (result[0] != '/') {
        result.insert(result.begin(), '/');
    }
    return result;
}

chmFile *toFile(uint64_t handle) {
    return reinterpret_cast<chmFile *>(static_cast<intptr_t>(handle));
}

bool resolveUnit(chmFile *file, const std::string &path, chmUnitInfo &info) {
    std::string normalized = normalizeChmPath(path);
    memset(&info, 0, sizeof(info));
    return chm_resolve_object(file, normalized.c_str(), &info) == CHM_RESOLVE_SUCCESS;
}

struct EnumContext {
    std::vector<std::string> paths;
};

int enumCallback(chmFile * /*file*/, chmUnitInfo *unit, void *context) {
    EnumContext *ctx = static_cast<EnumContext *>(context);
    if (unit && unit->path[0] != '\0') {
        ctx->paths.emplace_back(unit->path);
    }
    return CHM_ENUMERATOR_CONTINUE;
}

napi_value makeArrayBuffer(napi_env env, const unsigned char *data, size_t length) {
    napi_value result = nullptr;
    void *raw = nullptr;
    if (napi_create_arraybuffer(env, length, &raw, &result) != napi_ok) {
        napi_get_null(env, &result);
        return result;
    }
    if (length > 0 && raw != nullptr && data != nullptr) {
        memcpy(raw, data, length);
    }
    return result;
}

} // namespace

// chmOpen(path): 打开 CHM，成功返回句柄（bigint），失败返回 0。
static napi_value ChmOpen(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        return makeHandle(env, 0);
    }
    std::string filePath = getStringArg(env, args[0]);
    if (filePath.empty()) {
        return makeHandle(env, 0);
    }

    HarmonyFileStream *stream =
            static_cast<HarmonyFileStream *>(calloc(1, sizeof(HarmonyFileStream)));
    if (stream == nullptr) {
        return makeHandle(env, 0);
    }
    stream->fp = fopen(filePath.c_str(), "rb");
    if (stream->fp == nullptr) {
        free(stream);
        return makeHandle(env, 0);
    }
    stream->base.open = streamOpen;
    stream->base.read = streamRead;
    stream->base.close = streamClose;

    chmFile *file = chm_open(reinterpret_cast<chmExternalFileStream *>(stream));
    if (file == nullptr) {
        return makeHandle(env, 0);
    }
    return makeHandle(env, reinterpret_cast<uint64_t>(file));
}

// chmClose(handle): 关闭 CHM。
static napi_value ChmClose(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    chmFile *file = argc >= 1 ? toFile(getHandleArg(env, args[0])) : nullptr;
    if (file != nullptr) {
        chm_close(file);
    }
    return nullptr;
}

// chmList(handle): 返回 CHM 内所有普通文件路径（以 "/" 开头）。
static napi_value ChmList(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    chmFile *file = argc >= 1 ? toFile(getHandleArg(env, args[0])) : nullptr;

    napi_value result = nullptr;
    if (file == nullptr) {
        napi_create_array_with_length(env, 0, &result);
        return result;
    }

    EnumContext context;
    chm_enumerate(file, CHM_ENUMERATE_FILES | CHM_ENUMERATE_NORMAL, enumCallback, &context);

    napi_create_array_with_length(env, context.paths.size(), &result);
    for (size_t i = 0; i < context.paths.size(); i++) {
        napi_value item = nullptr;
        napi_create_string_utf8(env, context.paths[i].c_str(), NAPI_AUTO_LENGTH, &item);
        napi_set_element(env, result, static_cast<uint32_t>(i), item);
    }
    return result;
}

// chmResolve(handle, path): 返回 [start, length, space, flags]，不存在返回 null。
static napi_value ChmResolve(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr, nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    chmFile *file = argc >= 1 ? toFile(getHandleArg(env, args[0])) : nullptr;
    if (file == nullptr || argc < 2) {
        napi_value nullValue = nullptr;
        napi_get_null(env, &nullValue);
        return nullValue;
    }

    chmUnitInfo unitInfo;
    if (!resolveUnit(file, getStringArg(env, args[1]), unitInfo)) {
        napi_value nullValue = nullptr;
        napi_get_null(env, &nullValue);
        return nullValue;
    }

    napi_value result = nullptr;
    napi_create_array_with_length(env, 4, &result);
    double values[4] = {
        static_cast<double>(unitInfo.start),
        static_cast<double>(unitInfo.length),
        static_cast<double>(unitInfo.space),
        static_cast<double>(unitInfo.flags)
    };
    for (uint32_t i = 0; i < 4; i++) {
        napi_value item = nullptr;
        napi_create_double(env, values[i], &item);
        napi_set_element(env, result, i, item);
    }
    return result;
}

// chmRead(handle, path, offset, length): 读取部分数据（ArrayBuffer）。
static napi_value ChmRead(napi_env env, napi_callback_info info) {
    size_t argc = 4;
    napi_value args[4] = {nullptr, nullptr, nullptr, nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    chmFile *file = argc >= 1 ? toFile(getHandleArg(env, args[0])) : nullptr;
    if (file == nullptr || argc < 4) {
        return makeArrayBuffer(env, nullptr, 0);
    }

    int64_t offset = 0;
    int32_t length = 0;
    napi_get_value_int64(env, args[2], &offset);
    napi_get_value_int32(env, args[3], &length);
    if (offset < 0 || length <= 0) {
        return makeArrayBuffer(env, nullptr, 0);
    }

    chmUnitInfo unitInfo;
    if (!resolveUnit(file, getStringArg(env, args[1]), unitInfo)) {
        return makeArrayBuffer(env, nullptr, 0);
    }
    if (static_cast<LONGUINT64>(offset) >= unitInfo.length) {
        return makeArrayBuffer(env, nullptr, 0);
    }
    LONGUINT64 available = unitInfo.length - static_cast<LONGUINT64>(offset);
    if (static_cast<LONGUINT64>(length) > available) {
        length = static_cast<int32_t>(available);
    }

    std::vector<unsigned char> buffer(static_cast<size_t>(length));
    LONGINT64 got = chm_retrieve_object(file, &unitInfo, buffer.data(),
                                        static_cast<LONGUINT64>(offset), length);
    if (got <= 0) {
        return makeArrayBuffer(env, nullptr, 0);
    }
    return makeArrayBuffer(env, buffer.data(), static_cast<size_t>(got));
}

// chmReadAll(handle, path): 读取整个文件（ArrayBuffer，上限 64MB）。
static napi_value ChmReadAll(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr, nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    chmFile *file = argc >= 1 ? toFile(getHandleArg(env, args[0])) : nullptr;
    if (file == nullptr || argc < 2) {
        return makeArrayBuffer(env, nullptr, 0);
    }

    chmUnitInfo unitInfo;
    if (!resolveUnit(file, getStringArg(env, args[1]), unitInfo)) {
        return makeArrayBuffer(env, nullptr, 0);
    }
    if (unitInfo.length == 0 ||
        unitInfo.length > static_cast<LONGUINT64>(64 * 1024 * 1024)) {
        return makeArrayBuffer(env, nullptr, 0);
    }

    std::vector<unsigned char> buffer(static_cast<size_t>(unitInfo.length));
    LONGINT64 got = chm_retrieve_object(file, &unitInfo, buffer.data(), 0,
                                        static_cast<LONGINT64>(unitInfo.length));
    if (got <= 0) {
        return makeArrayBuffer(env, nullptr, 0);
    }
    return makeArrayBuffer(env, buffer.data(), static_cast<size_t>(got));
}

static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        DECLARE_NAPI_FUNCTION("chmOpen", ChmOpen),
        DECLARE_NAPI_FUNCTION("chmClose", ChmClose),
        DECLARE_NAPI_FUNCTION("chmList", ChmList),
        DECLARE_NAPI_FUNCTION("chmResolve", ChmResolve),
        DECLARE_NAPI_FUNCTION("chmRead", ChmRead),
        DECLARE_NAPI_FUNCTION("chmReadAll", ChmReadAll),
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}

static napi_module chmModule = {
    .nm_version = 1,
    .nm_flags = 1,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "chmcore",
    .nm_priv = nullptr,
    .reserved = {},
};

extern "C" __attribute__((constructor)) void RegisterChmModule(void) {
    napi_module_register(&chmModule);
}
