#!/usr/bin/env bash

echo "Exporting environment variables"
export PERL5LIB=./lib:$PERL5LIB
export SUBMAN_HOME=/projects/subman/
export SUBMAN_PORT=3000
export SUBMAN_HOST=0.0.0.0

echo 'pid ' `cat ./subman.pid` ' found, killing it ... '
cat $SUBMAN_HOME/subman.pid | xargs kill -9

perl -w $SUBMAN_HOME/script/subman_server.pl --pidfile $SUBMAN_HOME/subman.pid --host $SUBMAN_HOST --port $SUBMAN_PORT >> logs/subman_error.log 2>&1  &
sleep 3;

pid=`cat $SUBMAN_HOME/subman.pid`
echo $pid;
echo "Started process $pid. Application availble on http://localhost:$SUBMAN_PORT/, log is in logs/subman_error.log"


