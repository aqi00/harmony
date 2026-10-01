cmake_minimum_required(VERSION 3.5.2)
project(libdjvu)

set(CMAKE_CXX_STANDARD 14)
set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# djvulibre 编译宏（对齐原 jni/djvudroid/Android.mk）
add_compile_definitions(HAVE_CONFIG_H THREADMODEL=NOTHREADS DEBUGLVL=0)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-g)
else()
    add_compile_options(-O3)
endif()

include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/djvudroid
)

# ---- djvulibre 静态库（文件清单照搬 jni/djvudroid/Android.mk）----
add_library(djvudroid STATIC
    djvudroid/Arrays.cpp
    djvudroid/BSByteStream.cpp
    djvudroid/BSEncodeByteStream.cpp
    djvudroid/ByteStream.cpp
    djvudroid/DataPool.cpp
    djvudroid/DjVmDir.cpp
    djvudroid/DjVmDir0.cpp
    djvudroid/DjVmDoc.cpp
    djvudroid/DjVmNav.cpp
    djvudroid/DjVuAnno.cpp
    djvudroid/DjVuDocEditor.cpp
    djvudroid/DjVuDocument.cpp
    djvudroid/DjVuDumpHelper.cpp
    djvudroid/DjVuErrorList.cpp
    djvudroid/DjVuFile.cpp
    djvudroid/DjVuFileCache.cpp
    djvudroid/DjVuGlobal.cpp
    djvudroid/DjVuGlobalMemory.cpp
    djvudroid/DjVuImage.cpp
    djvudroid/DjVuInfo.cpp
    djvudroid/DjVuMessage.cpp
    djvudroid/DjVuMessageLite.cpp
    djvudroid/DjVuNavDir.cpp
    djvudroid/DjVuPalette.cpp
    djvudroid/DjVuPort.cpp
    djvudroid/DjVuText.cpp
    djvudroid/GBitmap.cpp
    djvudroid/GContainer.cpp
    djvudroid/GException.cpp
    djvudroid/GIFFManager.cpp
    djvudroid/GMapAreas.cpp
    djvudroid/GOS.cpp
    djvudroid/GPixmap.cpp
    djvudroid/GRect.cpp
    djvudroid/GScaler.cpp
    djvudroid/GSmartPointer.cpp
    djvudroid/GString.cpp
    djvudroid/GThreads.cpp
    djvudroid/GURL.cpp
    djvudroid/GUnicode.cpp
    djvudroid/IFFByteStream.cpp
    djvudroid/IW44EncodeCodec.cpp
    djvudroid/IW44Image.cpp
    djvudroid/JB2EncodeCodec.cpp
    djvudroid/JB2Image.cpp
    djvudroid/JPEGDecoder.cpp
    djvudroid/MMRDecoder.cpp
    djvudroid/MMX.cpp
    djvudroid/UnicodeByteStream.cpp
    djvudroid/XMLParser.cpp
    djvudroid/XMLTags.cpp
    djvudroid/ZPCodec.cpp
    djvudroid/atomic.cpp
    djvudroid/debug.cpp
    djvudroid/DjVuToPS.cpp
    djvudroid/ddjvuapi.cpp
    djvudroid/miniexp.cpp
)
target_include_directories(djvudroid PUBLIC ${NATIVERENDER_ROOT_PATH}/djvudroid)

# ---- NAPI 桥共享库 libdjvu.so ----
add_library(djvu SHARED
    napi_init.cpp
)
target_include_directories(djvu PRIVATE
    ${NATIVERENDER_ROOT_PATH}/djvudroid
)
target_link_libraries(djvu PUBLIC djvudroid)

# HarmonyOS NDK 系统库：NAPI + hilog（直接链接 .z.so，名称与 NDK 一致）
target_link_libraries(djvu PUBLIC libace_napi.z.so libhilog_ndk.z.so)

set_target_properties(djvu PROPERTIES OUTPUT_NAME "djvu")
