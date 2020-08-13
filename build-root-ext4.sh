#!/bin/sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

wget https://alpha.de.repo.voidlinux.org/live/current/void-armv7l-musl-ROOTFS-20191109.tar.xz

dd if=/dev/zero of=image.ext4 bs=1M count=256
mkfs.ext4 image.ext4
mkdir -p mountpoint 
mount -o loop image.ext4 mountpoint
tar -xvf void-armv7l-musl-ROOTFS-20191109.tar.xz -C mountpoint

cd mountpoint/

# Set the default terminal to kindle's default serial port.
cp -R ./etc/sv/agetty-tty1/ ./etc/sv/agetty-ttymxc0
rm -f ./etc/sv/agetty-ttymxc0/conf
cat <<EOT >> ./etc/sv/agetty-ttymxc0/conf
GETTY_ARGS="-L ttymxc0 115200 vt100 --noclear"
BAUD_RATE=115200
TERM_NAME=linux
EOT

rm -f ./etc/runit/runsvdir/default/*
ln -s /etc/sv/agetty-ttymxc0 ./etc/runit/runsvdir/default/agetty-ttymxc0

cd ../

umount mountpoint/
chmod 0755 mountpoint/
chmod 0755 image.ext4

