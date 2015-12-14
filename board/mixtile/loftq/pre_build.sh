#!/bin/sh

chmod +x output/target/lib/*
rm -rf output/target/init
rm -rf output/target/lib/modules
rm -rf output/target/system

(cd output/target && ln -s bin/busybox init)

cp -r board/mixtile/loftq/system output/target/
cp -r board/mixtile/loftq/modules output/target/lib

cat > output/target/etc/init.d/rcS << EOF
#!/bin/sh

mount -t devtmpfs none /dev
mkdir /dev/pts
mount -t devpts none /dev/pts
mount -t sysfs sysfs /sys
mkdir /dev/shm
mount -t tmpfs tmpfs /dev/shm
mknod /dev/mali c 230 0
hostname LoftQ
mkdir -p /boot
mount /dev/nanda /boot
MODULES_DIR=/lib/modules/\`uname -r\`

#####################################
# mount udisk partition
#####################################

if
fsck.fat -y /dev/mmcblk0p1 
then
    echo "udisk is completed!"
else
    mkfs.fat /dev/mmcblk0p1
fi

mkdir -p /mnt/udisk
mount /dev/mmcblk0p1 /mnt/udisk

#####################################
# load default modules
#####################################

# misc modules
modprobe bcmdhd

#####################################
# ethernet
#####################################
MAC_ADDR="\`uuidgen |awk -F- '{print \$5}'|sed 's/../&:/g'|sed 's/\(.\)$//' |cut -b3-17\`"

ifconfig eth0 hw ether "48\$MAC_ADDR"

ifconfig eth0 up
dhcpcd eth0 &

#####################################
# wifi auto start
#####################################
echo "Starting WiFi..."
wpa_supplicant -B -Dnl80211 -iwlan0 -c/etc/wpa_supplicant.conf 
sleep .5s
echo "WiFi should be started"
dhcpcd wlan0 &

udevd &

#####################################
# bluetooth auto start
#####################################
#echo "Starting bluetooth"
#echo -n "" > /dev/ttyS1
#brcm_patchram_plus -d --enable_hci --bd_addr 11:22:33:44:55:66 --no2bytes --tosleep 1000 --patchram /system/vendor/modules/bcm20710a1.hcd /dev/ttyS1
#hciattach /dev/ttyS1 any

EOF

sed -i '/TSLIB/d' output/target/etc/profile

echo "export TSLIB_TSEVENTTYPE=H3600" >> output/target/etc/profile
echo "export TSLIB_CONSOLEDEVICE=none" >> output/target/etc/profile
echo "export TSLIB_FBDEVICE=/dev/fb0" >> output/target/etc/profile
echo "export TSLIB_TSDEVICE=/dev/input/event2" >> output/target/etc/profile
echo "export TSLIB_CALIBFILE=/etc/pointercal" >> output/target/etc/profile
echo "export TSLIB_CONFFILE=/etc/ts.conf" >> output/target/etc/profile
echo "export TSLIB_PLUGINDIR=/usr/lib/ts" >> output/target/etc/profile
echo "" >> output/target/etc/profile






