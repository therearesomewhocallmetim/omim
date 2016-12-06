#!/usr/bin/env bash

GetCPUCores() {
  case "$OSTYPE" in
    # it's GitBash under Windows
    cygwin)    echo $NUMBER_OF_PROCESSORS
               ;;
    linux-gnu) grep -c ^processor /proc/cpuinfo 2>/dev/null
               ;;
    darwin*)   sysctl -n hw.ncpu
               ;;
    *)         echo "Unsupported platform in $0"
               exit 1
               ;;
  esac
  return 0
}

BuildCmake() {
  (
    SHADOW_DIR="$1"
    BUILD_TYPE="$2"

    mkdir -p "$SHADOW_DIR"
    cd "$SHADOW_DIR"
    pwd
    echo "Launching cmake..."

    echo ">>>>> CC is $CC"

    CC=$CC CXX=$CXX cmake \
     "-DCMAKE_SYSTEM_NAME=Android" \
     "-DCMAKE_ANDROID_ARCH_ABI=$ARCH" \
    "-DANDROID_NDK=/Users/Shared/android-ndk-r12b/" \
    "-DINCLUDE_DIRECTORIES=/Users/Shared/android-ndk-r12b/sources/cxx-stl/llvm-libc++" \
    ""
     "-DCMAKE_BUILD_TYPE=$BUILD_TYPE" "-DCMAKE_OSX_ARCHITECTURES=$ARCH" "-DNO_TESTS=TRUE -DPLATFORM=$PLATFORM" "$MY_PATH/../.." \
     "$MY_PATH/../.."
#    CC=$CC CXX=$CXX cmake "-DCMAKE_BUILD_TYPE=$BUILD_TYPE" -DCMAKE_OSX_ARCHITECTURES=$ARCH -DNO_TESTS=TRUE -DPLATFORM=$PLATFORM "$MY_PATH/../.."
#    make clean > /dev/null || true
    make -j \
    VERBOSE=1
  )
}

#    "-DCMAKE_CXX_FLAGS='std=c++0x -stdlib=libc++")" \
