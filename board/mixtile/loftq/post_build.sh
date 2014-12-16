#!/bin/sh

cp output/host/opt/ext-toolchain/arm-none-linux-gnueabi/libc/lib/* output/target/lib/ -pfr

chmod +x output/target/lib/*
rm -rf output/target/init

(cd output/target && ln -s bin/busybox init)

cat > output/target/etc/init.d/rcS << EOF
#!/bin/sh

mount -t devtmpfs none /dev
mkdir /dev/pts
mount -t devpts none /dev/pts
mount -t sysfs sysfs /sys
mknod /dev/mali c 230 0
hostname sun6i 
mkdir -p /boot
mount /dev/nanda /boot
MODULES_DIR=/lib/modules/\`uname -r\`

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

touch output/target/etc/init.d/auto_config_network

cat > output/target/etc/init.d/auto_config_network << EOF
#!/bin/sh

MAC_ADDR="\`uuidgen |awk -F- '{print \$5}'|sed 's/../&:/g'|sed 's/\(.\)$//' |cut -b3-17\`"

ifconfig eth0 hw ether "48\$MAC_ADDR"
ifconfig lo 127.0.0.1
udhcpc

EOF

chmod +x output/target/etc/init.d/auto_config_network

# mac addr referring process
TGT_DIR=output/target
TGT_FILE=$TGT_DIR/etc/init.d/S30platform

echo "###################################################################"

MAC_ADDR="3a:9d:33:28:d2:22"
CLIENT_IP_ADDR="192.168.3.122"
echo $MAC_ADDR
echo $CLIENT_IP_ADDR

touch $TGT_FILE
chmod +x $TGT_FILE
echo "#!/bin/sh" > $TGT_FILE
echo "ifconfig eth0 hw ether ${MAC_ADDR}" >> $TGT_FILE
echo "ifconfig eth0 $CLIENT_IP_ADDR" >> $TGT_FILE
echo "ifconfig lo 127.0.0.1" >> $TGT_FILE

echo "###################################################################"


