#***********************************************************************
# Copyright 2022 Massachusets Institute of Technology
# SPDX short identifier: BSD-2-Clause
#
# File Name:      CMakeLists.txt
# Program:        Common Evaluation Platform (CEP)
# Description:    CMake file
# Notes:          
#************************************************************************

project(helloworld C)
add_executable(helloworld helloworld.c)

target_include_directories(helloworld PRIVATE)

target_link_libraries(helloworld PRIVATE "gpiod")

set(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "Standard install prefix" FORCE)

install(TARGETS helloworld RUNTIME DESTINATION bin)