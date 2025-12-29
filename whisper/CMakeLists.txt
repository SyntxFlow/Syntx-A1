cmake_minimum_required(VERSION 3.16)
project(syntx LANGUAGES C CXX)

add_subdirectory(vendor/whisper)
add_library(lib
    STATIC
    ${CMAKE_SOURCE_DIR}/src/lib/wav_reader.cpp
)

add_executable(syntx
    src/main.cpp
)

target_include_directories(syntx PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

target_link_libraries(syntx 
    PRIVATE
    whisper
    lib
)