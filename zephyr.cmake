#if(CONFIG_CODEC2_USE_MODULE)
zephyr_include_directories(${PROJECT_BINARY_DIR})
zephyr_include_directories(${PROJECT_SOURCE_DIR}/src)

zephyr_compile_definitions(__LINUX_ERRNO_EXTENSIONS__) #not sure what this is

get_property(CODEC2_EXTRA_COMPILE_OPTIONS TARGET zephyr_interface PROPERTY INTERFACE_COMPILE_OPTIONS)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(MICROCONTROLLER_BUILD 1)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mlittle-endian -ffunction-sections -fdata-sections -g -O3")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -ffunction-sections -fdata-sections")

add_definitions(-DCORTEX_M33 -D__EMBEDDED__)
add_definitions(-DFREEDV_MODE_EN_DEFAULT=0  -DCODEC2_MODE_EN_DEFAULT=1 -DCODEC2_MODE_700C_EN=1)
                    
set(CMAKE_REQUIRED_FLAGS "")

set(LPCNET OFF CACHE BOOL "")
add_subdirectory(${codec2_SOURCE_DIR} ${codec2_BINARY_DIR} EXCLUDE_FROM_ALL)
