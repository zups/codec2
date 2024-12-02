#
# stm32f4 support for Codec2
#
# CMake configuration contributed by Richard Shaw (KF5OIM)
# Please report questions, comments, problems, or patches to the freetel
# mailing list: https://lists.sourceforge.net/lists/listinfo/freetel-codec2
#
cmake_minimum_required(VERSION 3.13)
project(CODEC2
    VERSION 1.2.0
    DESCRIPTION "Next-Generation Digital Voice for Two-Way Radio"
    HOMEPAGE_URL "https://www.rowetel.com/codec2.html"
    LANGUAGES C)

#zephyr_include_directories($ENV{LIB_LOCATION}/${INCLUDE_DIR})
#zephyr_link_libraries($ENV{LIB_LOCATION}/${LIB_DIR}/${LIB_NAME})
zephyr_get_include_directories_for_lang_as_string(       C includes)
zephyr_get_system_include_directories_for_lang_as_string(C system_includes)
zephyr_get_compile_definitions_for_lang_as_string(       C definitions)
zephyr_get_compile_options_for_lang_as_string(           C options)
set(external_project_cflags
      "${target_flag} ${includes} ${definitions} ${options} ${system_includes}"
        )

    #include(../stm32/cmake/gencodebooks.cmake)

#
# Prevent in-source builds
# If an in-source build is attempted, you will still need to clean up a few
# files manually.
#

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
  message(FATAL_ERROR "In-source builds in ${CMAKE_BINARY_DIR} are not "
   "allowed, please remove ./CMakeCache.txt and ./CMakeFiles/, create a "
   "separate build directory and run cmake from there.")
endif("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")

#include(cmake/STM32_Toolchain.cmake)

###################################################

set(FLOAT_TYPE "hard" CACHE STRING "Floating point: defaults to hard.")
#set(CMAKE_TOOLCHAIN_FILE "../stm32/cmake/STM32_Toolchain.cmake" CACHE STRING "Toolchain defs")

###################################################

#
# Find the git hash if this is a working copy.
#
if(EXISTS ${CMAKE_SOURCE_DIR}/.git)
    find_package(Git QUIET)
    if(Git_FOUND)
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" describe --always HEAD
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
            RESULT_VARIABLE res
            OUTPUT_VARIABLE FREEDV_HASH
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE)
        message(STATUS "freedv-gui current git hash: ${FREEDV_HASH}")
        add_definitions(-DGIT_HASH="${FREEDV_HASH}")
    else()
        message(WARNING "Git not found. Can not determine current commit hash.")
        add_definitions(-DGIT_HASH="Unknown")
    endif()
else()
        add_definitions(-DGIT_HASH="None")
endif()

set(LPCNET OFF CACHE BOOL "")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(MICROCONTROLLER_BUILD 1)
# Set default C flags.
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -std=gnu11 -mlittle-endian -mthumb -mthumb-interwork --specs=nano.specs -u_printf_float -mcpu=cortex-m33 -ffunction-sections -fdata-sections -O3")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -std=gnu11 -mlittle-endian -mthumb -mthumb-interwork -u_printf_float -mcpu=cortex-m33 -ffunction-sections -fdata-sections -O3")
#set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -ffunction-sections -fdata-sections")

add_definitions(-DCORTEX_M33 -D__EMBEDDED__)
#add_definitions(-DCORTEX_M4 -D__EMBEDDED__)
add_definitions(-DFREEDV_MODE_EN_DEFAULT=0 -DCODEC2_MODE_EN_DEFAULT=0 -DCODEC2_MODE_700C_EN=1)

if(FLOAT_TYPE STREQUAL "hard")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsingle-precision-constant -Wdouble-promotion -mfpu=fpv4-sp-d16 -mfloat-abi=hard -D__FPU_PRESENT=1 -D__FPU_USED=1")
    #CFLAGS += -fsingle-precision-constant
else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msoft-float")
endif()

option(VERIFY_OPT "Enable this for dump files to help verify optimization" OFF)
if(VERIFY_OPT)
    add_definitions(-DDUMP)
endif()

# Set default build type
if(NOT CMAKE_BUILD_TYPE)
    #set(CMAKE_BUILD_TYPE "Debug")
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    link_libraries(g m)
else()
    link_libraries(c m)
endif()

# Setup defaults that can't be set in the toolchain file
#set(CMAKE_EXE_LINKER_FLAGS "-u_init -T${CMAKE_SOURCE_DIR}/stm32_flash.ld -Xlinker --gc-sections")
#set(CMAKE_EXECUTABLE_SUFFIX_C ".elf")
#set(CMAKE_EXECUTABLE_SUFFIX_CXX ".elf")
#set(CMAKE_EXECUTABLE_SUFFIX_ASM ".elf")
#set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} -x assembler-with-cpp")

# Check build flags

message(STATUS "CMAKE_C_FLAGS: " ${CMAKE_C_FLAGS})
message(STATUS "CMAKE_ASM_FLAGS: " ${CMAKE_ASM_FLAGS})

###################################################

# STM32F4 Standard Peripheral Library

#include(cmake/STM32_Lib.cmake)

###################################################

# Macro for elf->bin
#macro(elf2bin target)
#    add_custom_command(TARGET ${target}
#    POST_BUILD COMMAND ${CMAKE_OBJCOPY} -O binary ${target}.elf ${target}.bin && ${CMAKE_OBJCOPY} -O ihex ${target}.elf ${target}.hex
#    COMMENT "Creating binary for ${target}")
#    set_source_files_properties(${target}.bin PROPERTIES GENERATED TRUE)
#    set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" APPEND PROPERTY
#    ADDITIONAL_MAKE_CLEAN_FILES ${target}.bin ${target}.hex)
#endmacro()

# This macro just adds generation of a map file with the same name as the executable and .map suffix
# to the linker command line. This works in older Cmake version (versions >= 3.13 have target_link_options)
# it should be a one to one replacement for add_executable
#macro(add_mapped_executable target)
#    add_executable(${target} ${ARGN})
#    target_link_libraries(${target} "-Wl,-Map=$<TARGET_PROPERTY:NAME>.map")
#    set_source_files_properties(${target}.map PROPERTIES GENERATED TRUE)
#    set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" APPEND PROPERTY
#    ADDITIONAL_MAKE_CLEAN_FILES ${target}.map)
#endmacro()

#include(CTest)
include_directories(../stm32/src ../stm32/zephyr_inc ../src inc ${PROJECT_BINARY_DIR})

#add_subdirectory(unittest/src)

# Codec 2

# Output path is such that #include <codec2/version.h> in codec2.h works
set(CODEC2_VERSION_PATH "${PROJECT_BINARY_DIR}/codec2")
configure_file ("${PROJECT_SOURCE_DIR}/../cmake/version.h.in"
                "${CODEC2_VERSION_PATH}/version.h" )


#set(CODEC2_SRC ../src)
#set(CODEC2_GEN_CODEBOOK_SRC ../build/src)
#set(CODEC2_SRCS
set(CODEC2_SRC ../src)
set(CODEC2_STM32 ../stm32)
set(CODEC2_GEN_CODEBOOK_SRC ../build/src)
set(CODEC2_SRCS
${CODEC2_SRC}/lpc.c
${CODEC2_SRC}/nlp.c
${CODEC2_SRC}/postfilter.c
${CODEC2_SRC}/sine.c
${CODEC2_SRC}/codec2.c
${CODEC2_SRC}/codec2_fft.c
${CODEC2_SRC}/gp_interleaver.c
${CODEC2_SRC}/interldpc.c
${CODEC2_SRC}/kiss_fft.c
${CODEC2_SRC}/kiss_fftr.c
${CODEC2_SRC}/interp.c
${CODEC2_SRC}/lsp.c
${CODEC2_SRC}/ofdm.c
${CODEC2_SRC}/ofdm_mode.c
${CODEC2_SRC}/phase.c
${CODEC2_SRC}/quantise.c
${CODEC2_SRC}/pack.c
${CODEC2_SRC}/dump.c
${CODEC2_SRC}/cohpsk.c
${CODEC2_SRC}/fdmdv.c
${CODEC2_SRC}/freedv_api.c
${CODEC2_SRC}/freedv_1600.c
${CODEC2_SRC}/freedv_700.c
${CODEC2_SRC}/freedv_2020.c
${CODEC2_SRC}/freedv_fsk.c
${CODEC2_SRC}/filter.c
${CODEC2_SRC}/varicode.c
${CODEC2_SRC}/golay23.c
${CODEC2_SRC}/freedv_data_channel.c
${CODEC2_SRC}/newamp1.c
${CODEC2_SRC}/mbest.c
${CODEC2_SRC}/HRA_112_112.c
${CODEC2_SRC}/HRA_56_56.c
${CODEC2_SRC}/linreg.c
${CODEC2_SRC}/mpdecode_core.c
${CODEC2_SRC}/ldpc_codes.c
${CODEC2_SRC}/phi0.c
${CODEC2_SRC}/HRAb_396_504.c
${CODEC2_SRC}/codec2_math_arm.c
#${CODEC2_SRC}/generate_codebook.c

#${CODEC2_STM32}/codebooks/codebook.c
#${CODEC2_STM32}/codebooks/codebookd.c
#${CODEC2_STM32}/codebooks/codebookjmv.c
#${CODEC2_STM32}/codebooks/codebookge.c
#${CODEC2_STM32}/codebooks/codebooknewamp1_energy.c
#${CODEC2_STM32}/codebooks/codebooknewamp1.c
${CODEC2_STM32}/codebooks/codebook.c
${CODEC2_STM32}/codebooks/codebookd.c
${CODEC2_STM32}/codebooks/codebookjmv.c
${CODEC2_STM32}/codebooks/codebookge.c
${CODEC2_STM32}/codebooks/codebooknewamp1_energy.c
${CODEC2_STM32}/codebooks/codebooknewamp1.c
${CODEC2_STM32}/src/memtools.c
)

zephyr_library()

zephyr_library_include_directories(${CODEC2_SRC})
zephyr_library_sources(${CODEC2_SRCS})
#add_library(codec2_prof STATIC ${CODEC2_SRCS})
#target_compile_definitions(codec2_prof PRIVATE PROFILE)
#add_library(codec2 STATIC ${CODEC2_SRCS})
#add_library(codec2_prof STATIC ${CODEC2_SRCS})
#target_compile_definitions(codec2_prof PRIVATE PROFILE)
