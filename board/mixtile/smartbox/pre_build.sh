#!/bin/sh

chmod +x output/target/lib/*
rm -rf output/target/init
rm -rf output/target/lib/modules

(cd output/target && ln -s bin/busybox init)

cp -r board/mixtile/smartbox/system output/target/
cp -r board/mixtile/smartbox/modules output/target/lib

cat > output/target/etc/init.d/rcS << EOF
#!/bin/sh

mount -t devtmpfs none /dev
mkdir /dev/pts
mount -t devpts none /dev/pts
mount -t sysfs sysfs /sys
mkdir /dev/shm
mount -t tmpfs tmpfs /dev/shm
mknod /dev/mali c 230 0
hostname Smartbox
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
# loop network
#####################################
ifconfig lo 127.0.0.1

#####################################
# ethernet
#####################################
ifconfig eth0 up
udhcpc eth0 &
udevd &
#####################################
# wifi auto start
#####################################
echo "Starting WiFi..."
wpa_supplicant -B -Dnl80211 -iwlan0 -c/etc/wpa_supplicant.conf 
sleep .5s
echo "WiFi should be started"
dhcpcd wlan0 &

#####################################
# bluetooth auto start
#####################################
#echo "Starting bluetooth"
#echo -n "" > /dev/ttyS1
#brcm_patchram_plus -d --enable_hci --bd_addr 11:22:33:44:55:66 --no2bytes --tosleep 1000 --patchram /system/vendor/modules/bcm20710a1.hcd /dev/ttyS1
#hciattach /dev/ttyS1 any

# Start all init scripts in /etc/init.d
# executing them in numerical order.
#
for i in /etc/init.d/S??* ;do
     # Ignore dangling symlinks (if any).
     [ ! -f "$i" ] && continue

     case "$i" in
     *.sh)
         # Source shell script for speed.
         (
         trap - INT QUIT TSTP
         set start
         . $i
         )
         ;;
     *)
         # No sh extension, so fork subprocess.
         $i start
         ;;
     esac
done
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

