cmake_minimum_required(VERSION 3.5.2)

project(chmcore)

set(CMAKE_C_STANDARD 99)

# chmlib（chm_lib.c / lzx.c）+ NAPI 桥
add_library(chmcore SHARED
    chm_lib.c
    lzx.c
    napi_init.cpp)

target_compile_options(chmcore PRIVATE
    -D_FILE_OFFSET_BITS=64
    -D_LARGEFILE_SOURCE
    -Wno-unused-variable
    -Wno-unused-but-set-variable
    -Wno-sign-compare)

# HarmonyOS NDK 系统库：NAPI
target_link_libraries(chmcore PUBLIC libace_napi.z.so)
