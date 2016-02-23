#!/bin/bash
scriptdir=$(cd $(dirname $0); pwd)
: ${basedir:=$(cd $(dirname $scriptdir); pwd)}

set -e

# initialize a remote host: transfer files and run setup

host=$1

ssh "$host" date +%FT%T

if ! ssh $host test -d /greenfox; then
  ssh $host sudo mkdir -p /greenfox/software /greenfox/scripts
  ssh $host sudo chown -R ubuntu /greenfox
fi
rsync -av $basedir/software/ $host:/greenfox/software/
rsync -av $basedir/scripts/ $host:/greenfox/scripts/

ssh $host /greenfox/scripts/setup_jdk.sh

ssh $host /greenfox/scripts/setup_redis.sh

ssh $host /greenfox/scripts/setup_wildfly.sh
