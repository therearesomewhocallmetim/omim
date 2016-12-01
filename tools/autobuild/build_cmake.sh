#!/bin/bash
set -e -x -u

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

source "$MY_PATH/detect_qmake.sh"
source "$MY_PATH/build_functions.sh"

# Prints number of cores to stdout
#GetCPUCores() {
#  case "$OSTYPE" in
#    # it's GitBash under Windows
#    cygwin)    echo $NUMBER_OF_PROCESSORS
#               ;;
#    linux-gnu) grep -c ^processor /proc/cpuinfo 2>/dev/null
#               ;;
#    darwin*)   sysctl -n hw.ncpu
#               ;;
#    *)         echo "Unsupported platform in $0"
#               exit 1
#               ;;
#  esac
#  return 0
#}


# Replaces "/cygwin/c" prefix with "c:" one on Windows platform.
# Does nothing under other OS.
# 1st param: path to be modified.
StripCygwinPrefix() {
  if [[ $(GetNdkHost) == "windows-x86_64" ]]; then
    echo "c:`(echo "$1" | cut -c 12-)`"
    return 0
  fi

  echo "$1"
  return 0
}

# 1st param: shadow directory path
# 2nd param: mkspec
# 3rd param: additional qmake parameters
BuildQt() {
  (

    echo ">>>> CALLING BUILD QT"
    SHADOW_DIR="$1"
    QMAKE_PARAMS="$2"

    echo "SHADOW_DIR= ${SHADOW_DIR}"
    echo ">>>>>> QMAKE_PARAMS: $QMAKE_PARAMS"

    mkdir -p "$SHADOW_DIR"
    cd "$SHADOW_DIR"
    echo ">>>> Launching CMAKE..."
    # This call is needed to correctly rebuild c++ sources after switching between branches with added or removed source files.
    # Otherwise we get build errors.
    cmake -r  "$(StripCygwinPrefix $MY_PATH)/../.."
#    make clean > /dev/null || true
    make -j $(GetCPUCores) VERBOSE=1
  )
}
