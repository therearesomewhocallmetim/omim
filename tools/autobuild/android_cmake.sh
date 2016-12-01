# Script builds only C++ native libs. To build also jni part see another script: eclipse[*].sh

set -e -u -x

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

if [[ $# < 1 ]]; then
  echo "Usage: $0 <debug|release|production> [armeabi-v7a|x86] [android-PLATFORM_NUMBER]"
  exit 1
fi
CONFIGURATION="$1"

source "$MY_PATH/build_functions.sh"
source "$MY_PATH/ndk_helper.sh"

MKSPEC="$MY_PATH/../mkspecs/android-clang"
QMAKE_PARAMS="CONFIG+=${CONFIGURATION}"
SHADOW_DIR_BASE="$MY_PATH/../../../omim-android"
export AR=arm-linux-androideabi-ar

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


GCC_VERSION=4.8
CLANG_VERSION=3.9
ANDROID_PLATFORM=android-15

#MAKEFILE_GENERATOR = UNIX
#QMAKE_COMPILER=$NDK_ROOT/toolchains/llvm-3.6/prebuilt/$NDK_HOST/bin/clang # for 12
#QMAKE_COMPILER=$NDK_ROOT/toolchains/llvm/prebuilt/$NDK_HOST/bin/clang # for 10
QMAKE_COMPILER=$NDK_ROOT/toolchains/llvm/prebuilt/$NDK_HOST/bin/clang #for 11
QMAKE_CC=$QMAKE_COMPILER
#QMAKE_CXX=$NDK_ROOT/toolchains/llvm-3.6/prebuilt/$NDK_HOST/bin/clang++
QMAKE_CXX="$QMAKE_CC++"
QMAKE_LINK_C=$QMAKE_CC
QMAKE_LINK_C_SHLIB=$QMAKE_CC
QMAKE_LINK=$QMAKE_CXX
QMAKE_LINK_SHLIB=$QMAKE_CXX

export CC=$QMAKE_CC
export CXX=$QMAKE_CXX


#QMAKE_CFLAGS_RELEASE   *= -O3 -g -DNDEBUG -DRELEASE -D_RELEASE
#QMAKE_CXXFLAGS_RELEASE *= $QMAKE_CFLAGS_RELEASE
#QMAKE_CFLAGS_DEBUG     *= -O0 -g -DDEBUG -D_DEBUG
#QMAKE_CXXFLAGS_DEBUG   *= $QMAKE_CFLAGS_DEBUG

BASE_CXX_INCLUDE_PATH=$NDK_ROOT/sources/cxx-stl/llvm-libc++
BASE_GNUSTL_INCLUDE_PATH=$NDK_ROOT/sources/cxx-stl/gnu-libstdc++/$GCC_VERSION

#export CC=$QMAKE_CC
#export CXX=$QMAKE_CXX

export INCLUDE_DIRECTORIES+="$BASE_CXX_INCLUDE_PATH;$BASE_GNUSTL_INCLUDE_PATH"


    GCC_TOOLCHAIN=$NDK_ROOT/toolchains/arm-linux-androideabi-$GCC_VERSION/prebuilt/$NDK_HOST
#    QMAKE_CFLAGS   *= -fpic -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -mthumb -fomit-frame-pointer -fno-strict-aliasing -fno-integrated-as
#
    PLATFORM_INCLUDE_PATH=$NDK_ROOT/platforms/$ANDROID_PLATFORM/arch-arm/usr/include
    ABI_INCLUDE_PATH=$BASE_CXX_INCLUDE_PATH/../llvm-libc++abi/libcxxabi/include

    export INCLUDE_DIRECTORIES+=";$PLATFORM_INCLUDE_PATH;$ABI_INCLUDE_PATH"
    AR_FULL_PATH=$NDK_ROOT/toolchains/arm-linux-androideabi-$GCC_VERSION/prebuilt/$NDK_HOST/bin/arm-linux-androideabi-ar
export CMAKE_AR=$AR_FULL_PATH
export CMAKE_RANLIB=$AR_FULL_PATH


for abi in "${NDK_ABI_LIST[@]}"; do
  SHADOW_DIR="${SHADOW_DIR_BASE}-${CONFIGURATION}-${abi}"
  export ARCH="$abi"
  export NDK_ABI="$abi"
  echo ">>>> CONFIGURATION: ${CONFIGURATION}"
    export PLATFORM="android-something"
  BuildCmake "$SHADOW_DIR" "Release" 1>&2 || ( echo "ERROR while building $abi config"; exit 1 )
done
