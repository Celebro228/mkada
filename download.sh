#!/bin/sh

linux_major=7
linux_minor=2
linux_patch=15

util_linux_major=2
util_linux_minor=42
util_linux_patch=4

nano_major=9
nano_minor=3

glibc="2.44"
dash="0.5.13.5"
toybox="0.8.9"
ncurses="6.6"
#gzip="1.15"
#tar="1.35"
#gettext="1.0"
#zlib="1.3.2"
#ianaetc="20261022"
#dinit=""
#glibc=""
#nano=""
#util-linux=""

load_func() {
    echo "$1 (v$2) download"
    curl $3/"$1"-"$2".tar.gz -o $1.tar.gz
    tar -xvf $1.tar.gz
    rm $1.tar.gz
    mv $1-"$2" $1
}

linux="$linux_major.$linux_minor.$linux_patch"
utillinux="$util_linux_major.$util_linux_minor.$util_linux_patch"
nano="$nano_major.$nano_minor"

mkdir sources
cd sources

all_load() {
    load_func linux $linux https://www.kernel.org/pub/linux/kernel/v$linux_major.x
    load_func util-linux $utillinux https://www.kernel.org/pub/linux/utils/util-linux/v$util_linux_major."$util_linux_minor"
    load_func glibc $glibc https://ftp.gnu.org/gnu/glibc
    load_func dash $dash http://gondor.apana.org.au/~herbert/dash/files
    load_func toybox $toybox https://landley.net/toybox/downloads
    load_func nano $nano https://www.nano-editor.org/dist/v$nano_major
    load_func ncurses $ncurses https://ftp.gnu.org/gnu/ncurses
    #load_func gzip $gzip https://ftp.gnu.org/gnu/gzip
    #load_func tar $tar https://ftp.gnu.org/gnu/tar
    #load_func gettext $gettext https://ftp.gnu.org/pub/gnu/gettext
    #load_func zlib $zlib https://zlib.net
    #load_func iana-etc $ianaetc https://github.com/Mic92/iana-etc/releases/download/"$ianaetc"
}

#all_load
