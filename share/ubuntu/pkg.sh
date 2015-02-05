#!/bin/bash
#set -x

#desktop
pkg_dev="build-essential vim tig git cmake tmux clang gcin gcin-gtk2-immodule fonts-noto wine byobu aptitude keepass2"
pkg_sa="iotop gparted synaptic"
pkg_media="qbittorrent smplayer shutter"
pkg_lib_common="autotools-dev automake libtool"
pkg_lib_pcman="libglib2.0-dev libgtk2.0-dev libltdl-dev intltool" 
pkg_lib_qemu="libfdt-dev libgles2-mesa-dev libsasl2-dev libjpeg-turbo8-dev libspice-server-dev"
pkg_gem5="scons mercurial hg-fast-export swig libprotobuf-dev"

pkg_all="$pkg_dev $pkg_sa $pkg_media $pkg_lib_common $pkg_lib_pcman $pkg_lib_qemu $pkg_gem5"

sudo apt-get install $pkg_all
