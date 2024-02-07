#!/bin/sh

platform=$(uname -m)
arch=""

if [ "$platform" = "aarch64" ]; then
    arch=64
elif [ "$platform" = "armv7l" ]; then
    arch=32
fi

flash_partition9() {
    mkdir -p /backup
	mount -t ext4 /dev/mmcblk0p8 /backup
	gunzip -c /backup/backup-$arch.gz | dd of=/dev/mmcblk0p9 bs=1024
}
echo "正在恢复系统刷机中，不要操作！不要断电！"
flash_partition9

dd of=/dev/mmcblk0p2 if=/etc/bootargs/bootargs9-${arch}.bin bs=1024 count=1024 conv=fsync
dd of=/dev/mmcblk0p5 if=/etc/bootargs/logo.img bs=1024 count=4096
sleep 2
sync
umount /backup
reboot

