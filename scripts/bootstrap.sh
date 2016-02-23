#!/bin/bash
scriptdir=$(cd $(dirname $0); pwd)
: ${basedir:=$(cd $(dirname $scriptdir); pwd)}

cache_url=http://texasparagus.com/software-93ccbd71.tar

set -e

# initialize a remote host: transfer files and run setup

host=$1

ssh "$host" date +%FT%T

if ! ssh $host test -d /greenfox; then
  ssh $host sudo mkdir -p /greenfox/software /greenfox/scripts
  ssh $host sudo chown -R ubuntu /greenfox
fi

rsync -av $basedir/scripts/ $host:/greenfox/scripts/

# attempt to fetch this content from an Internet cache
if ! ssh $host "ls -l /greenfox/software/jdk*"; then
  echo downloading from texasparagus ...
  ssh $host "curl -s $cache_url | tar xCvf /greenfox - || true"
fi

rsync -av $basedir/software/ $host:/greenfox/software/

ssh $host /greenfox/scripts/setup_jdk.sh

ssh $host /greenfox/scripts/setup_redis.sh

ssh $host /greenfox/scripts/setup_wildfly.sh
