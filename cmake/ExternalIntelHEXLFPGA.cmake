# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.

FetchContent_Declare(
    hexl-fpga
    PREFIX hexl-fpga
    GIT_REPOSITORY https://github.com/intel/hexl-fpga.git
    GIT_TAG v2.0-rc1
)
FetchContent_GetProperties(hexl-fpga)

if(NOT hexl-fpga_POPULATED)
    FetchContent_Populate(hexl-fpga)
    set(CMAKE_C_COMPILER ${CMAKE_C_COMPILER} CACHE STRING "" FORCE)
    set(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER} CACHE STRING "" FORCE)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX} CACHE STRING "" FORCE)
    set(EXCLUDE_FROM_ALL TRUE)

    mark_as_advanced(BUILD_HEXL-FPGA)
    mark_as_advanced(INSTALL_HEXL-FPGA)
    mark_as_advanced(FETCHCONTENT_SOURCE_DIR_HEXL-FPGA)
    mark_as_advanced(FETCHCONTENT_UPDATES_DISCONNECTED_HEXL-FPGA)

    add_subdirectory(
        ${hexl-fpga_SOURCE_DIR}
        ${hexl-fpga_SOURCE_DIR}/../hexl-fpga-build
        EXCLUDE_FROM_ALL
    )
endif()
