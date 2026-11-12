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
    ln -s usr/lib lib2
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
    cp $files/ld.so.conf etc/
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

# Btw
sc_install() {
    cd $sources/"$1"
    ./configure --prefix "$ada"
    make -j $(nproc)
    make install -j $(nproc)
}

# Build
linux() {
    cd $sources/linux
    make defconfig
    make -j $(nproc)
    cp arch/x86/boot/bzImage $ada/boot/
}

utillinux() {
    cd $sources/util-linux
    ./configure --prefix "$ada" \
        --without-python \
        --disable-liblastlog2
    make -j $(nproc)
    make install -j $(nproc)
}

glibc() {
    cd $sources/glibc
    mkdir build
    cd build
    ../configure --prefix "$ada" --libdir=/lib #--disable-nscd
    make -j $(nproc)
    make install -j $(nproc)
    #make localedata/install-locales
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

ncurses() {
    cd $sources/ncurses
    ./configure --prefix "$ada" \
        --with-shared \
        --with-termlib \
        --enable-widec \
        --with-versioned-syms
    make -j $(nproc)
    make install -j $(nproc)
    cd $ada
    ln -s libncursesw.so.6 lib/libncurses.so.6
    ln -s libtinfow.so.6 lib/libtinfo.so.6
    ldconfig -v -r ./
}

gettext() {
    cd $sources/gettext
    ./configure --disable-shared
    make
    cp gettext-tools/src/{msgfmt,msgmerge,xgettext} $ada/usr/bin
}

ianaetc() {
    cd $sources/iana-etc
    cp services protocols $ada/etc
}

all_build() {
    linux
    dash
    toybox
    utillinux
    sc_install nano
    glibc
    ncurses
    #sc_install gzip
    #sc_install tar
    #gettext
    #sc_install zlib
    #ianaetc
}

deletes() {
    cd $ada
    rm -rf usr/share/{info,man,doc}/*
    find usr/{lib,libexec} -name \*.la -delete
}

run() {
    base_dirs
    other_dirs
    links
    file_copys
    #file_creates
    #not_everyone
    all_build
    deletes
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
