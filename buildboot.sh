#!/bin/zsh

set -e

if ! [[ -f $1 ]] || ! [ -n $2 ]; then
  echo usage: `basename $0` SOURCE_IMG DESTINATION_IMG
  exit 1
fi

export PATH=$TOP/.vendor/mkbootimg:$PATH

get_address() {
  echo 0x`cat $OUT/mkbootimg/stdout | sed -n "s/^$1: */obase=16; /p" | bc`
}

echo -e \\n Unpacking... \\n

mkdir -p $OUT/mkbootimg
unpack_bootimg --boot_img $1 --out $OUT/mkbootimg | tee $OUT/mkbootimg/stdout

echo -e \\n Repacking... \\c

mkbootimg      --kernel $OUT/arch/arm64/boot/Image.gz-dtb \
               --ramdisk $OUT/mkbootimg/ramdisk \
               --cmdline 'androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 sched_enable_hmp=1 sched_enable_power_aware=1 service_locator.enable=1 swiotlb=2048 androidboot.selinux=permissive buildvariant=user' \
               --base 0x00 \
               --kernel_offset `get_address 'kernel load address'` \
               --ramdisk_offset `get_address 'ramdisk load address'`  \
               --second_offset `get_address 'second bootloader load address'` \
               --tags_offset `get_address 'kernel tags load address'` \
               --pagesize `cat $OUT/mkbootimg/stdout | sed -n 's/^page size: *//p'` \
               --output $2 && echo done

echo -e \\n Comparing... \\n

unpack_bootimg --boot_img $2 --out /dev/null 2>/dev/null > $OUT/mkbootimg/stdout.new || true
diff -y --text --suppress-common-lines $OUT/mkbootimg/stdout $OUT/mkbootimg/stdout.new

rm -rf $OUT/mkbootimg
