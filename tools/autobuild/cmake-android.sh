#!/usr/bin/env bash

# Script builds only C++ native libs. To build also jni part see another script: eclipse[*].sh

set -e -u -x

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

if [[ $# < 1 ]]; then
  echo "Usage: $0 <debug|release|production> [armeabi-v7a|x86] [android-PLATFORM_NUMBER]"
  exit 1
fi
CONFIGURATION="$1"

CMAKE="/Users/Shared/AndroidSdk/cmake/3.6.3155560/bin/cmake"


BuildQt() {
  (
    SHADOW_DIR="$1"
    MKSPEC="$2"
    QMAKE_PARAMS="$3"

    export PATH=/Users/Shared/android-ndk-r13b/toolchains/x86-4.9/prebuilt/darwin-x86_64/bin:$PATH

    mkdir -p "$SHADOW_DIR"
    cd "$SHADOW_DIR"
    echo "Launching CMake..."
    # This call is needed to correctly rebuild c++ sources after switching between branches with added or removed source files.
    # Otherwise we get build errors.
    "$CMAKE" \
     "-DSKIP_TESTS=TRUE" \
     "-DPLATFORM=android-smth" \
    "-DANDROID_ABI=$NDK_ABI" \
    "-DANDROID_NDK=/Users/Shared/android-ndk-r13b/" \
    "-DANDROID_TOOLCHAIN=/Users/Shared/toolchain-86" \
     "-DCMAKE_TOOLCHAIN_FILE=/Users/Shared/android-ndk-r13b/build/cmake/android.toolchain.cmake" \
    "-DANDROID_NATIVE_API_LEVEL=23" \
    "-DANDROID_TOOLCHAIN=clang" \
    "-DCMAKE_MAKE_PROGRAM=/Users/Shared/AndroidSdk/cmake/3.6.3155560/bin/ninja" \
    "-DANDROID_STL=c++_static" \
    "-DANDROID_CPP_FEATURES='rtti exceptions'" \
    "-GAndroid Gradle - Ninja" \
    "$MY_PATH/../../"

    #"-DANDROID_STL=c++_static" \
    #    "-DANDROID_STL=system" \
#"-DBOOST_INCLUDEDIR=/usr/local/include" \
#   "-DBOOST_LIBRARYDIR=/usr/local/lib" \

#     -r CONFIG-=sdk "$QMAKE_PARAMS" -spec "$(StripCygwinPrefix $MKSPEC)" "$(StripCygwinPrefix $MY_PATH)/../../omim.pro"
#    make clean > /dev/null || true

       pwd
ASFLAGS="-D__ANDROID__" CROSS=i686-linux-android- LDFLAGS="--sysroot=/Users/Shared/android-ndk-r13b/platforms/android-24/arch-x86" ./configure --target=x86-android-gcc --extra-cflags="--sysroot=/Users/Shared/android-ndk-r13b/platforms/android-24/arch-x86" --disable-examples

      /Users/Shared/AndroidSdk/cmake/3.6.3155560/bin/ninja   -j8
  )
}


source "$MY_PATH/ndk_helper.sh"

MKSPEC="$MY_PATH/../mkspecs/android-clang"
QMAKE_PARAMS="CONFIG+=${CONFIGURATION}"
SHADOW_DIR_BASE="$MY_PATH/../../../omim-android"

# Try to read ndk root path from android/local.properties file
export NDK_ROOT=$(GetNdkRoot) || ( echo "Can't read NDK root path from android/local.properties"; exit 1 )
export NDK_HOST=$(GetNdkHost) || ( echo "Can't get your OS type, please check tools/autobuild/ndk_helper.sh script"; exit 1 )
if [[ $# > 2 ]] ; then
  export NDK_PLATFORM=$3
fi

if [[ $# > 1 ]] ; then
  NDK_ABI_LIST=$2
else
  NDK_ABI_LIST=(armeabi-v7a x86)
fi


for abi in "${NDK_ABI_LIST[@]}"; do
  SHADOW_DIR="${SHADOW_DIR_BASE}-${CONFIGURATION}-${abi}/out/${CONFIGURATION}"
  export NDK_ABI="$abi"
  BuildQt "$SHADOW_DIR" "$MKSPEC" "$QMAKE_PARAMS" 1>&2 || ( echo "ERROR while building $abi config"; exit 1 )
done
