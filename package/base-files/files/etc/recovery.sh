#!/bin/sh

sleep 1

flash_partition9() {
    mkdir -p /backup
	mount -t ext4 /dev/mmcblk0p8 /backup
	backup_file=$(ls /backup|grep ".*backup.*\.gz$"|head -1)
	model=$(echo $backup_file|sed -r "s/backup-(.*?)-.*/\1/g")
	arch=$(echo $backup_file|sed -r "s/backup-(.*?)-(.*)\.gz/\2/g")
	sleep 1
	gunzip -c /backup/$backup_file | dd of=/dev/mmcblk0p9 bs=1024
}
#disable double flash when usered flash mode 
if [ -b /dev/sda1 ];then
	mkdir -p /mnt
	mount /dev/sda1 /mnt
fi
if [ -f /mnt/fastboot.bin ];then
	mv /mnt/fastboot.bin /mnt/fastboot_falshed.bin
	sync
	umount /mnt
fi
flash_partition9
[ "$arch" = "64" ] && suffix64="-64"
dd of=/dev/mmcblk0p2 if=/etc/bootargs/bootargs9-${model}${suffix64}.bin bs=1024 count=1024
dd of=/dev/mmcblk0p5 if=/etc/bootargs/logo.img bs=1024 count=4096
sleep 2
sync
umount /backup
reboot

