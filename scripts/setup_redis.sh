#!/bin/bash
set -e

: ${install_prefix:=/greenfox}
: ${software_dir:=$install_prefix/software}
: ${wildfly_dir:=$(basename $wildfly_file .zip)}
: ${wildfly_cli:=$install_prefix/wildfly/bin/jboss-cli.sh}

: ${requirepass:=HZfbd_I_G6WV43tuBkMr}

export JAVA_HOME=$install_prefix/jdk
export PATH=$JAVA_HOME/bin:$PATH

: ${deploy_wars:="greenfox-pup-0.1-SNAPSHOT.war  greenfox-retwisj.war"}

# expect this directory already populated
ls -l $wildfly_file

redis-server --version || need_pkgs="redis-server"
if test -n "$need_pkgs"; then
  sudo apt-get install -y $need_pkgs
fi

# set the client auth password
sudo sed -i -e "s/^#* *requirepass .*/requirepass $requirepass/" /etc/redis/redis.conf

# TODO - set up master slave?

sudo update-rc.d redis-server defaults

sudo service redis-server restart
