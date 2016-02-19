#!/bin/bash
set -e

: ${install_prefix:=/greenfox}
: ${software_dir:=$install_prefix/software}
: ${jdk_file:=$software_dir/jdk-8u73-linux-x64.tar.gz}
: ${jdk_dir:=jdk1.8.0_73}

# expect this directory already populated
ls -l $jdk_file

if ! test -d $install_prefix/jdk; then
  tar xCzf $install_prefix $jdk_file
  ln -s $jdk_dir $install_prefix/jdk
fi
