#!/bin/sh

flash_mode=$(dmesg 2> /dev/null | grep "flash_mode")
sleep 8

flash_partition9() {
    mkdir -p /backup
	mount -t ext2 /dev/mmcblk0p8 /backup
	backup_file=$(ls /backup|grep ".*backup.*\.gz$"|head -1)
	model=$(echo $backup_file|sed -r "s/backup-(.*?)-.*/\1/g")
	arch=$(echo $backup_file|sed -r "s/backup-(.*?)-(.*)\.gz/\2/g")
	sleep 1
	gunzip -c /backup/$backup_file | dd of=/dev/mmcblk0p9 bs=1024
}

if [ -n "$flash_mode" ]; then
    mkdir -p /mnt
	mount /dev/sda1 /mnt
	echo "mounting and flashing NAS to mmcblk0p8, please waiting...."
	[ -d /mnt/mv100 ] && folder=mv100
	[ -d /mnt/mv200 ] && folder=mv200
	[ -d /mnt/mv300 ] && folder=mv300
	dd if=/mnt/${folder}/www_histb_com.img of=/dev/mmcblk0p8 bs=1024
	echo "flashing ubuntu_NAS to mmcblk0p9, please waiting...."
	flash_partition9
	mv /mnt/fastboot.bin /mnt/fastboot_falshed.bin
else
	echo "flash the backup partitions. Please waiting....."
	flash_partition9
fi
sleep 2

[ "$arch" = "64" ] && suffix64="-64"
dd of=/dev/mmcblk0p2 if=/etc/bootargs/bootargs9-${model}${suffix64}.bin bs=1024 count=1024
dd of=/dev/mmcblk0p5 if=/etc/bootargs/logo.img bs=1024 count=4096
sleep 2
umount /mnt
umount /backup
reboot

