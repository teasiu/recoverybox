#!/bin/sh

platform=$(uname -m)
arch=""

if [ "$platform" = "aarch64" ]; then
    arch=64
elif [ "$platform" = "armv7l" ]; then
    arch=32
fi

flash_partition4() {
    mkdir -p /backup
	mount -t ext4 /dev/mmcblk0p3 /backup
	gunzip -c /backup/backup-$arch.gz | dd of=/dev/mmcblk0p4 conv=fsync
}
echo "正在恢复系统刷机中，不要操作！不要断电！"
flash_partition4
resize2fs /dev/mmcblk0p4
configfile="/boot/armbianEnv.txt"
sed -e 's,rootdev=.*,rootdev=UUID=eb3496f9-e4fb-4311-8e5f-79a0239f71b2,g' -i $configfile
sleep 2
sync
umount /backup
reboot

