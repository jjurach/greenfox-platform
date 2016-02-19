#!/bin/bash
set -e

prefix=/greenfox
app=wildfly
export JAVA_HOME=$prefix/jdk
export _jboss_home=$prefix/$app
export PATH=$JAVA_HOME/bin:$_jboss_home/bin:$PATH

cd $_jboss_home

logdir=$(cd $_jboss_home/..; pwd)/logs
mkdir -p $logdir
pidfile=$logdir/$app.pid
outfile=$logdir/${app}.out

cmd=$1

function check_pidfile () {
  local pidfile=$1
  if test -f $pidfile && ! kill -0 $(cat $pidfile) 2>/dev/null; then
    echo removing stale pidfile $pidfile
    rm $pidfile
  fi
  if test -f $pidfile; then
    cat $pidfile
  fi
}

if test -z "$cmd"; then
  echo Usage: $0 '<start> | <stop> | <status>'
  exit 0

elif test "$cmd" = start; then

  pid=$(check_pidfile $pidfile)
  if test -n "$pid"; then
    echo Already running with PID $pid
    exit 0
  fi

  $_jboss_home/bin/standalone.sh \
    -Djboss.server.default.config=standalone-ha.xml \
    -Djboss.bind.address=0.0.0.0 \
    -Djboss.http.port=8080 \
    -Djboss.bind.address.management=0.0.0.0 \
    -Djboss.management.http.port=9990 \
      >> $outfile 2>&1 &
  spid=$!
  for i in 1 2 3; do
    ps -ef | egrep -v grep | grep $spid.*bin/java | awk '{print $2}' > $pidfile
    test -s $pidfile && break
    sleep 2
  done
  pid=$(cat $pidfile)
  if test -z $pid; then
    echo $app did not appear to start?
    rm $pidfile
    exit 1
  fi

  sleep 2
  if ! kill -0 $pid 2>/dev/null; then
    echo PID $pid appeared to stop'?'
  else
    echo $pid > $pidfile
    echo Running with PID $pid and output $outfile
  fi

elif test "$cmd" = status; then

  pid=$(check_pidfile $pidfile)
  if test -n "$pid"; then
    echo Running with PID $pid
  else
    echo Not running
  fi

elif test "$cmd" = stop; then

  pid=$(check_pidfile $pidfile)
  if test -z "$pid"; then
    echo Already not running
    exit 0
  fi

  cli=$_jboss_home/bin/jboss-cli.sh
  echo shutting down with $cli
  $cli --connect command=:shutdown

  if kill -0 $pid 2>/dev/null; then
    echo PID $pid remainins running.
  fi
  echo Process $pid killed.

  rm $pidfile

else

  echo Invalid command "'$cmd'"
  exit 1

fi
