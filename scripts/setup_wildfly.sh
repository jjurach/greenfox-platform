#!/bin/bash
set -e

: ${install_prefix:=/greenfox}
: ${software_dir:=$install_prefix/software}
: ${wildfly_file:=$software_dir/wildfly-9.0.2.Final.zip}
: ${wildfly_dir:=$(basename $wildfly_file .zip)}
: ${wildfly_cli:=$install_prefix/wildfly/bin/jboss-cli.sh}

: ${deploy_wars:="greenfox-pup-0.1-SNAPSHOT.war  greenfox-retwisj.war"}

# expect this directory already populated
ls -l $wildfly_file

if ! unzip -v >/dev/null; then
  sudo apt-get install unzip
fi
if ! git --version >/dev/null; then
  sudo apt-get install git
fi

cd $install_prefix 

if ! test -d $wildfly_dir; then
  unzip -qo $wildfly_file
  ln -s $wildfly_dir wildfly
fi

scripts/wildfly-ctl.sh start

if ! grep -q ^admin= wildfly/standalone/configuration/mgmt-users.properties; then
  # admin creation
  wildfly/bin/add-user.sh admin qKzrOmiU9vCnW72RWjQ2

  # initialize deployments
  sleep 6
  for war in $deploy_wars; do
    echo "deploy --force software/$war" | $wildfly_cli --connect
  done
fi
