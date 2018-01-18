#!/bin/zsh

set -e

if ! [ -n "$1" ]; then
  echo usage: `basename $0` DESTINATION_ZIP
  exit 1
fi

echo -e \\n Preparing... \\n

cp -r $TOP/.vendor/AnyKernel2 $OUT
echo Paranoid Android kernel for OP3/3T by Chris Lahaye | tee $OUT/AnyKernel2/banner

echo -e \\n Building ZIP file... \\n

cp -v $OUT/arch/arm64/boot/Image.gz-dtb $OUT/AnyKernel2/Image.gz-dtb

(cd $OUT/AnyKernel2 && zip -r $OUT/kernel.zip * -x "README.md")

echo -e \\n Finalizing... \\n

cp -v $OUT/kernel.zip $1

rm -rf $OUT/AnyKernel2
