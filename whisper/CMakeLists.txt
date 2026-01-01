cmake_minimum_required(VERSION 3.16)
project(syntx LANGUAGES C CXX)

find_package(OpenMP REQUIRED)

add_library(syntx_lib STATIC ${CMAKE_SOURCE_DIR}/src/lib/wav_reader.cpp)

add_library(whisper SHARED IMPORTED)
add_library(ggml SHARED IMPORTED)
add_library(ggml_base SHARED IMPORTED)
add_library(ggml_cpu SHARED IMPORTED)
add_library(samplerate SHARED IMPORTED)

if (WIN32)
    set_target_properties(whisper PROPERTIES
        IMPORTED_IMPLIB "${CMAKE_SOURCE_DIR}/prebuilt/whisper/windows/libwhisper.dll.a"
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/whisper/windows/bin/libwhisper.dll"
    )
    set_target_properties(ggml PROPERTIES
        IMPORTED_IMPLIB "${CMAKE_SOURCE_DIR}/prebuilt/whisper/windows/libggml.dll.a"
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/whisper/windows/bin/ggml.dll"
    )
    set_target_properties(ggml_base PROPERTIES
        IMPORTED_IMPLIB "${CMAKE_SOURCE_DIR}/prebuilt/whisper/windows/libggml-base.dll.a"
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/whisper/windows/bin/ggml-base.dll"
    )
    set_target_properties(ggml_cpu PROPERTIES
        IMPORTED_IMPLIB "${CMAKE_SOURCE_DIR}/prebuilt/whisper/windows/libggml-cpu.dll.a"
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/whisper/windows/bin/ggml-cpu.dll"
    )

    set_target_properties(samplerate PROPERTIES
        IMPORTED_IMPLIB "${CMAKE_SOURCE_DIR}/prebuilt/libsamplerate/windows/libsamplerate.dll.a"
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/libsamplerate/windows/bin/libsamplerate-0.dll"
    )
elseif (ANDROID)
    set_target_properties(whisper PROPERTIES
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/whisper/android/libwhisper.so"
    )
    set_target_properties(ggml PROPERTIES
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/whisper/android/libggml.so"
    )
    set_target_properties(ggml_base PROPERTIES
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/whisper/android/libggml-base.so"
    )
    set_target_properties(ggml_cpu PROPERTIES
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/whisper/android/libggml-cpu.so"
    )

    set_target_properties(samplerate PROPERTIES
        IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/prebuilt/libsamplerate/android/libsamplerate.so"
    )
endif()

if (ANDROID)
    add_library(syntx SHARED
        src/main.cpp
    )
else()
    add_executable(syntx
        src/main.cpp
    )
endif()

target_include_directories(syntx PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

target_link_libraries(syntx 
    PRIVATE
    syntx_lib
    whisper
    ggml
    ggml_base
    ggml_cpu
    samplerate
    OpenMP::OpenMP_CXX
)