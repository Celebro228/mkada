#!/bin/sh
mkdir ada

this=$(pwd)
sources=$this/sources
files=$this/files
ada=$this/ada

base_dirs() {
    cd $ada
    mkdir proc sys dev
    mkdir boot home mnt opt srv
    mkdir run var etc media
}

other_dirs() {
    cd $ada
    mkdir -p etc/{opt,sysconfig}
    mkdir -p media/{floppy,cdrom}
    mkdir -p usr/{bin,lib}
    mkdir -p usr/lib/firmware
    mkdir -p usr/{,local/}{include,src}
    mkdir -p usr/lib/locale
    mkdir -p usr/local/{bin,lib,sbin}
    mkdir -p usr/{,local/}share/{color,dict,doc,info,locale,man}
    mkdir -p usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -p usr/{,local/}share/man/man{1..8}
    mkdir -p var/{cache,local,log,mail,opt,spool}
    mkdir -p var/lib/{color,misc,locate,hwclock}
}

links() {
    cd $ada
    ln -sf run var/run
    ln -sf run/lock var/lock
    ln -s proc/self/mounts etc/mtab
    ln -s usr/bin bin
    ln -s usr/bin sbin
    ln -s usr/lib lib
    ln -s usr/lib lib64
    cd usr
    ln -s bin sbin
    ln -s lib lib64
}

file_copys() {
    cd $ada
    cp $files/hosts etc/
    cp $files/passwd etc/
    cp $files/group etc/
    cp $files/nsswitch.conf etc/
}

file_creates() {
    cd $ada
    touch /etc/ld.so.conf
    touch var/log/{btmp,lastlog,faillog,wtmp}
    chgrp utmp var/log/lastlog
}

not_everyone() {
    cd $ada
    install -d -m 0750 root
    install -d -m 1777 tmp var/tmp
    chown -R root:root $ada/{usr,var,etc,lib64}
    chmod 664  var/log/lastlog
    chmod 600  var/log/btmp
}


# Права доступа

# Files



# Btw
mk() {
    make -j $(nproc)
    make install -j $(nproc)
}

sc_install() {
    cd $sources/"$1"
    ./configure --prefix "$ada"
    mk
}

# Build
glibc() {
    cd $sources/glibc
    mkdir build
    cd build
    ../configure --prefix "$ada" --disable-nscd
    mk
    make localedata/install-locales
}

dash() {
    sc_install dash
    cd $ada/usr/bin
    ln -s dash sh
}

toybox() {
    cd $sources/toybox
    make defconfig
    make -j $(nproc)
    cp ./toybox $ada/usr/bin/
    cd $ada/usr/bin/
    for util in $(./toybox); do
        ln -s ./toybox "$util"
    done
}

gettext() {
    cd $sources/gettext
    ./configure --disable-shared
    make
    cp gettext-tools/src/{msgfmt,msgmerge,xgettext} $ada/usr/bin
}

utillinux() {
    cd $sources/util-linux
    ./configure --prefix "$ada" \
        --without-python
    mk
}

ianaetc() {
    cd $sources/iana-etc
    cp services protocols $ada/etc
}

all_build() {
    glibc
    dash
    toybox
    sc_install gzip
    sc_install tar
    gettext
    sc_install zlib
    ianaetc
}

deletes() {
    cd $ada
    rm -rf usr/share/{info,man,doc}/*
    find usr/{lib,libexec} -name \*.la -delete
}

# Delete


#all_build
#deletes

# Post
#cd $this
#

#mount -v --bind /dev $ada/dev
#mount -vt devpts devpts -o gid=5,mode=0620 $ada/dev/pts
#mount -vt proc proc $ada/proc
#mount -vt sysfs sysfs $ada/sys
#mount -vt tmpfs tmpfs $ada/run

#if [ -h $ada/dev/shm ]; then
#  install -v -d -m 1777 $ada$(realpath /dev/shm)
#else
#  mount -vt tmpfs -o nosuid,nodev tmpfs $ada/dev/shm
#fi
