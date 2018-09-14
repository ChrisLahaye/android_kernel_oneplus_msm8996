#!/bin/zsh

set -e

if ! [ -x "$(command -v cpupower)" ]; then
  echo Installing cpupower...
  yay -Sy --noconfirm cpupower
fi

echo Changing CPUfreq governor to performance...
sudo cpupower frequency-set -g performance

echo Installing dependencies...

if ! [ -x "$(command -v ccache)" ]; then
  echo Installing ccache...
  yay -Sy --noconfirm ccache
fi

if [ ! -d ".vendor" ]; then
  mkdir .vendor

  echo Installing AnyKernel2...
  mkdir .vendor/AnyKernel2
  git clone git@github.com:MSF-Jarvis/AnyKernel2.git .vendor/AnyKernel2

  echo Installing GCC toolchain build script...
  mkdir .vendor/gcc
  git clone git@github.com:nathanchance/build-tools-gcc.git .vendor/gcc

  echo Building GCC for arm64...
  (cd .vendor/gcc && .build -a arm64 -s gnu -v 7 -V)

  echo Building GCC for arm...
  (cd .vendor/gcc && .build -a arm -s gnu -v 7 -V)

  echo Installing mkbootimg...
  mkdir .vendor/mkbootimg
  curl -L --progress https://android.googlesource.com/platform/system/core/+archive/master/mkbootimg.tar.gz \
    | tar xzf - -C .vendor/mkbootimg
fi

export TOP=`readlink -f $(dirname "$0")`
export ARCH=arm64
export CCACHE_DIR=.ccache
export CROSS_COMPILE=$TOP/.vendor/gcc/aarch64-linux-gnu/bin/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=$TOP/.vendor/gcc/arm-linux-gnueabi/bin/arm-linux-gnueabi-
export OUT=/tmp/out
export MAKEFLAGS="-j`expr $(nproc) \* 2` O=$OUT"
export USE_CCACHE=1

ccache -M 50G

exec zsh
