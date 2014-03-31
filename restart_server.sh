#!/usr/bin/env bash

echo "Exporting environment variables"
export PERL5LIB=./lib:$PERL5LIB
export CHARGEMONK_HOME=/projects/chargemonk/
export CHARGEMONK_PORT=3000
export CHARGEMONK_HOST=0.0.0.0

echo 'pid ' `cat ./chargemonk.pid` ' found, killing it ... '
cat $CHARGEMONK_HOME/chargemonk.pid | xargs kill -9

perl -w $CHARGEMONK_HOME/script/chargemonk_server.pl --pidfile $CHARGEMONK_HOME/chargemonk.pid --host $CHARGEMONK_HOST --port $CHARGEMONK_PORT >> logs/chargemonk_error.log 2>&1  &
sleep 3;

pid=`cat $CHARGEMONK_HOME/chargemonk.pid`
echo $pid;
echo "Started process $pid. Application availble on http://localhost:$CHARGEMONK_PORT/, log is in logs/chargemonk_error.log"


