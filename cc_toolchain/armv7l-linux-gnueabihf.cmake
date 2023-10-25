#
# CMake Toolchain file for cross-compiling for armv7l-linux-gnueabihf.
#
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv7l)

set(ARM_GCC_VERSION_LIST 7;8;9;10;11;12;13;14;15)
foreach(GCC_VER IN LISTS ARM_GCC_VERSION_LIST)
  if(EXISTS "/usr/bin/arm-linux-gnueabihf-gcc-${GCC_VER}")
    set(CMAKE_C_COMPILER "/usr/bin/arm-linux-gnueabihf-gcc-${GCC_VER}")
    set(CMAKE_CXX_COMPILER "/usr/bin/arm-linux-gnueabihf-g++-${GCC_VER}")
    break()
  endif()
endforeach()

set(CMAKE_FIND_ROOT_PATH /usr/arm-linux-gnueabihf)

set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
