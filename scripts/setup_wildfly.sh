#!/bin/bash
set -e

: ${install_prefix:=/greenfox}
: ${software_dir:=$install_prefix/software}
: ${wildfly_file:=$software_dir/wildfly-9.0.2.Final.zip}
: ${wildfly_subdir:=$(basename $wildfly_file .zip)}
: ${wildfly_dir:=$install_prefix/wildfly}
: ${wildfly_cli:=$wildfly_dir/bin/jboss-cli.sh}
: ${wildfly_ctl:=$install_prefix/scripts/wildfly-ctl.sh}

: ${adminpass:=qKzrOmiU9vCnW72RWjQ2}

export JAVA_HOME=$install_prefix/jdk
export PATH=$JAVA_HOME/bin:$PATH

: ${deploy_wars:="greenfox-pup-0.1-SNAPSHOT.war  greenfox-retwisj.war"}

# expect this directory already populated
ls -l $wildfly_file

unzip -v >/dev/null || need_pkgs="$need_pkgs unzip"
git --version >/dev/null || need_pkgs="$need_pkgs git"
if test -n "$need_pkgs"; then
  sudo apt-get install -y $need_pkgs
fi

cd $install_prefix 

if ! test -d $wildfly_subdir; then
  unzip -qo $wildfly_file
  ln -s $wildfly_subdir wildfly
fi

$wildfly_ctl start

if ! crontab -l | egrep -v '^#' | grep -q $wildfly_ctl; then
  (crontab -l; echo "@reboot $wildfly_ctl start") | crontab
fi

if ! grep -q ^admin= wildfly/standalone/configuration/mgmt-users.properties; then
  # admin creation
  wildfly/bin/add-user.sh admin $adminpass

  # initialize deployments
  sleep 6
  for war in $deploy_wars; do
    echo "deploy --force software/$war" | $wildfly_cli --connect
  done
fi
