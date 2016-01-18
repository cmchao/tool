#!/bin/bash
#set -x

# detect root permission
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

#add ppa
ppa_all="ppa:git-core/ppa"
for item in $ppa_all; do
    add-apt-repository $item
done

#add i386 support
#reference : http://askubuntu.com/questions/454253/how-to-run-32-bit-app-in-ubuntu-64-bit
dpkg --add-architecture i386
apt-get update
apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386


#desktop
pkg_dev="build-essential vim tig git git-svn cmake gcovr tmux clang byobu texinfo"
pkg_dev="$pkg_dev fonts-noto wine byobu keepass2 tree doxygen"
pkg_sa="aptitude iotop gparted synaptic curl iftop htop nfs-common ntp"
pkg_compress="rar pxz dictzip"
pkg_media="qbittorrent smplayer shutter"
pkg_lib_common="autotools-dev automake libtool"
pkg_lib_pcman="libglib2.0-dev libgtk2.0-dev libltdl-dev intltool" 
pkg_lib_qemu="libfdt-dev libgles2-mesa-dev libsasl2-dev libjpeg-turbo8-dev libspice-server-dev"
pkg_gem5="scons mercurial hg-fast-export swig libprotobuf-dev protobuf-compiler"
pkg_gem5="$gem5 python-dev libgoogle-perftools-dev"
pkg_pkg="pip"

pkg_all="$pkg_dev $pkg_sa $pkg_compress $pkg_media $pkg_lib_common $pkg_lib_pcman $pkg_lib_qemu $pkg_gem5 $pkg_pkg"

apt-get install $pkg_all
