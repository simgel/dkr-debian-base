#!/bin/bash

set -e

# crreate new source list
rm -f /etc/apt/sources.list
echo "deb http://mirror.leaseweb.net/debian bookworm main contrib" > /etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security bookworm-security main contrib" >> /etc/apt/sources.list
echo "deb http://mirror.leaseweb.net/debian bookworm-updates main contrib" >> /etc/apt/sources.list

echo "nameserver 9.9.9.9" > /etc/resolv.conf

# install debootstrap
apt update -qq
apt upgrade -qqy
apt install -qqy debootstrap bsdmainutils


# create base layout
mkdir -p /docker/debian
cd /docker/debian

debootstrap --arch amd64 --variant=minbase bookworm ./chroot-bookworm http://mirror.leaseweb.net/debian

echo "nameserver 9.9.9.9" > chroot-bookworm/etc/resolv.conf

rm -f chroot-bookworm/etc/apt/sources.list
echo "deb http://mirror.leaseweb.net/debian bookworm main contrib" > chroot-bookworm/etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security bookworm-security main contrib" >> chroot-bookworm/etc/apt/sources.list
echo "deb http://mirror.leaseweb.net/debian bookworm-updates main contrib" >> chroot-bookworm/etc/apt/sources.list


chroot chroot-bookworm apt update -qq
chroot chroot-bookworm apt upgrade -qqy
chroot chroot-bookworm apt install -qqy bsdmainutils

# minimize
rm -rf chroot-bookworm/var/cache/apt/*
rm -rf chroot-bookworm/var/lib/apt/lists/*
rm -rf chroot-bookworm/var/log/*

# further minimization
# see https://github.com/debuerreotype/debuerreotype/blob/master/scripts/.slimify-excludes
# see https://github.com/debuerreotype/debuerreotype/blob/master/scripts/.slimify-includes
rm -rf chroot-bookworm/usr/share/locale/*
rm -rf chroot-bookworm/usr/share/man/*

mkdir -p chroot-bookworm/usr/share/doc.new
for i in chroot-bookworm/usr/share/doc/*/copyright; do echo "${i}" | sed -e "s/^chroot-bookworm\/usr\/share\/doc\///" | xargs -i dirname "{}" | xargs -i mkdir -p chroot-bookworm/usr/share/doc.new/{}; done
for i in chroot-bookworm/usr/share/doc/*/copyright; do echo "${i}" | sed -e "s/^chroot-bookworm\/usr\/share\/doc\///" | xargs -i cp chroot-bookworm/usr/share/doc/{} chroot-bookworm/usr/share/doc.new/{}; done
rm -rf chroot-bookworm/usr/share/doc
mv chroot-bookworm/usr/share/doc.new chroot-bookworm/usr/share/doc

# unqiue id
mkdir -p chroot-bookworm/opt/dkr-image/simgel/
hexdump -n 32 -e '4/4 "%8x"' /dev/urandom > chroot-bookworm/opt/dkr-image/simgel/dkr-debian-base.id

# final tar for image creation
cd chroot-bookworm
tar cpf /docker/debian/bookworm.tar .
