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

    cmake="/Users/Shared/AndroidSdk/cmake/3.6.3155560/bin/cmake"

#Error while executing '/Users/Shared/AndroidSdk/cmake/3.6.3155560/bin/cmake' with arguments {-H/Users/t.danshin/Documents/projects/omim -B/Users/t.danshin/Documents/projects/omim/android/.externalNativeBuild/cmake/preinstallBeta/armeabi -GAndroid Gradle - Ninja -DANDROID_ABI=armeabi -DANDROID_NDK=/Users/Shared/android-ndk-r12b -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=/Users/t.danshin/Documents/projects/omim/android/build/intermediates/cmake/preinstall/beta/obj/armeabi -DCMAKE_BUILD_TYPE=Release -DCMAKE_MAKE_PROGRAM=/Users/Shared/AndroidSdk/cmake/3.6.3155560/bin/ninja -DCMAKE_TOOLCHAIN_FILE=/Users/Shared/AndroidSdk/cmake/3.6.3155560/android.toolchain.cmake -DANDROID_NATIVE_API_LEVEL=15}

#    "-B/Users/t.danshin/Documents/projects/omim/android/.externalNativeBuild/cmake/preinstallBeta/armeabi" \
#    "-H/Users/t.danshin/Documents/projects/omim" \

    #CC=$CC CXX=$CXX
    $cmake \
    "-GAndroid Gradle - Ninja" \
    "-DANDROID_ABI=armeabi" \
    "-DANDROID_NDK=/Users/Shared/android-ndk-r12b" \
    "-DCMAKE_BUILD_TYPE=Release" \
    "-DCMAKE_MAKE_PROGRAM=/Users/Shared/AndroidSdk/cmake/3.6.3155560/bin/ninja" \
    "-DCMAKE_TOOLCHAIN_FILE=/Users/Shared/AndroidSdk/cmake/3.6.3155560/android.toolchain.cmake" \
    "-DANDROID_NATIVE_API_LEVEL=15"\
    "-DPLATFORM=$PLATFORM" "$MY_PATH/../.."

#    "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=/Users/t.danshin/Documents/projects/omim/android/build/intermediates/cmake/preinstall/beta/obj/armeabi" \
#     "-DCMAKE_SYSTEM_NAME=Android" \
#     "-DCMAKE_ANDROID_ARCH_ABI=$ARCH" \
#    "-DANDROID_NDK=/Users/Shared/android-ndk-r12b/" \
#    "-DINCLUDE_DIRECTORIES=/Users/Shared/android-ndk-r12b/sources/cxx-stl/llvm-libc++" \
#    "-DCMAKE_CXX_COMPILER=$CXX" \
#    "-DCMAKE_C_COMPILER=$CC" \
#     "-DCMAKE_BUILD_TYPE=$BUILD_TYPE" "-DNO_TESTS=TRUE"  \
#    CC=$CC CXX=$CXX cmake "-DCMAKE_BUILD_TYPE=$BUILD_TYPE" -DCMAKE_OSX_ARCHITECTURES=$ARCH -DNO_TESTS=TRUE -DPLATFORM=$PLATFORM "$MY_PATH/../.."
#    make clean > /dev/null || true
    make -j \
    VERBOSE=1
  )
}

#    "-DCMAKE_CXX_FLAGS='std=c++0x -stdlib=libc++")" \
