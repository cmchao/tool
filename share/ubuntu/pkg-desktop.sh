#!/bin/bash
#set -x

#add ppa
ppa_all="ppa:git-core/ppa"
for item in $ppa_all; do
    sudo add-apt-repository $item
done

#desktop
pkg_dev="build-essential vim tig git git-svn cmake gcovr tmux clang byobu"
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

sudo apt-get install $pkg_all
