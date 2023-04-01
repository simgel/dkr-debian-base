#!/bin/bash

set -e

# crreate new source list
rm -f /etc/apt/sources.list
echo "deb http://mirror.leaseweb.net/debian bullseye main contrib" > /etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security bullseye-security main contrib" >> /etc/apt/sources.list
echo "deb http://mirror.leaseweb.net/debian bullseye-updates main contrib" >> /etc/apt/sources.list

echo "nameserver 9.9.9.9" > /etc/resolv.conf

# install debootstrap
apt update -qq
apt upgrade -qqy
apt install -qqy debootstrap bsdmainutils


# create base layout
mkdir -p /docker/debian
cd /docker/debian

debootstrap --arch amd64 --variant=minbase bullseye ./chroot-bullseye http://mirror.leaseweb.net/debian

echo "nameserver 9.9.9.9" > chroot-bullseye/etc/resolv.conf

rm -f chroot-bullseye/etc/apt/sources.list
echo "deb http://mirror.leaseweb.net/debian bullseye main contrib" > chroot-bullseye/etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security bullseye-security main contrib" >> chroot-bullseye/etc/apt/sources.list
echo "deb http://mirror.leaseweb.net/debian bullseye-updates main contrib" >> chroot-bullseye/etc/apt/sources.list


chroot chroot-bullseye apt update -qq
chroot chroot-bullseye apt upgrade -qqy
chroot chroot-bullseye apt install -qqy bsdmainutils

# minimize
rm -rf chroot-bullseye/var/cache/apt/*
rm -rf chroot-bullseye/var/lib/apt/lists/*

# further minimization
# see https://github.com/debuerreotype/debuerreotype/blob/master/scripts/.slimify-excludes
# see https://github.com/debuerreotype/debuerreotype/blob/master/scripts/.slimify-includes
rm -rf chroot-bullseye/usr/share/locale/*
rm -rf chroot-bullseye/usr/share/man/*

mkdir -p chroot-bullseye/usr/share/doc.new
for i in chroot-bullseye/usr/share/doc/*/copyright; do echo "${i}" | sed -e "s/^chroot-bullseye\/usr\/share\/doc\///" | xargs -i dirname "{}" | xargs -i mkdir -p chroot-bullseye/usr/share/doc.new/{}; done
for i in chroot-bullseye/usr/share/doc/*/copyright; do echo "${i}" | sed -e "s/^chroot-bullseye\/usr\/share\/doc\///" | xargs -i cp chroot-bullseye/usr/share/doc/{} chroot-bullseye/usr/share/doc.new/{}; done
rm -rf chroot-bullseye/usr/share/doc
mv chroot-bullseye/usr/share/doc.new chroot-bullseye/usr/share/doc

# unqiue id
mkdir -p chroot-bullseye/opt/dkr-image/simgel/
hexdump -n 32 -e '4/4 "%8x"' /dev/urandom > chroot-bullseye/opt/dkr-image/simgel/dkr-debian-base.id

# final tar for image creation
cd chroot-bullseye
tar cpf /docker/debian/bullseye.tar .
