#!/usr/bin/env bash

function __run_pulsar_job {
  # run $bin/pulsar, exit if exit value indicates error

  echo "$PULSARJOB $@" ; # echo command and arguments
  "$PULSARJOB" "$@"

  RETCODE=$?
  if [ $RETCODE -ne 0 ]
  then
      echo "Error running:"
      echo "  $PULSARJOB $@"
      echo "Failed with exit value $RETCODE."
      exit $RETCODE
  fi
}

function __is_crawl_loop_stopped {
  STOP=0
  if [ -e ".STOP" ] || [ -e ".KEEP_STOP" ]; then
   if [ -e ".STOP" ]; then
     mv .STOP ".STOP_EXECUTED_`date +%Y%m%d.%H%M%S`"
   fi

    STOP=1
  fi

  (( $STOP==1 )) && return 0 || return 1
}

function __check_index_server_available {
  for i in {1..200}
  do
    wget -q --spider $SOLR_TEST_URL

    if (( $?==0 )); then
      return 0;
    fi

    if ( __is_crawl_loop_stopped ); then
      echo "STOP file found - escaping loop"
      exit 0
    fi

    echo "Index server not available, check 15s later ..."
    sleep 15s
  done

  echo "Index server is gone."
  return 1
}

function __check_master_available
{
  wget -q --spider http://localhost:8182/config

  if (( $?==0 )); then
    return 0;
  fi

  return 1;
}

function __check_pid_before_start() {
    #ckeck if the process is not running
    mkdir -p ${PULSAR_PID_DIR}
    if [ -f $pid ]; then
      if kill -0 `cat $pid` > /dev/null 2>&1; then
        echo $command running as process `cat $pid`.  Stop it first.
        exit 1
      fi
    fi
}

function pulsar_rotate_log ()
{
    log=$1;
    num=5;
    if [ -n "$2" ]; then
    num=$2
    fi
    if [ -f "$log" ]; then # rotate logs
    while [ $num -gt 1 ]; do
        prev=`expr $num - 1`
        [ -f "$log.$prev" ] && mv -f "$log.$prev" "$log.$num"
        num=$prev
    done
    mv -f "$log" "$log.$num";
    fi
}

function check_before_start() {
    #ckeck if the process is not running
    mkdir -p "$PULSAR_PID_DIR"
    if [ -f $pid ]; then
      if kill -0 `cat $pid` > /dev/null 2>&1; then
        echo $command running as process `cat $pid`.  Stop it first.
        exit 1
      fi
    fi
}

function wait_until_done ()
{
    p=$1
    cnt=${PULSAR_SLAVE_TIMEOUT:-300}
    origcnt=$cnt
    while kill -0 $p > /dev/null 2>&1; do
      if [ $cnt -gt 1 ]; then
        cnt=`expr $cnt - 1`
        sleep 1
      else
        echo "Process did not complete after $origcnt seconds, killing."
        kill -9 $p
        exit 1
      fi
    done
    return 0
}

#Shared function to wait for a process end. Take the pid and the command name as parameters
function waitForProcessEnd() {
  pidKilled=$1
  commandName=$2
  processedAt=`date +%s`
  while kill -0 $pidKilled > /dev/null 2>&1;
   do
     echo -n "."
     sleep 1;
     # if process persists more than $HBASE_STOP_TIMEOUT (default 1200 sec) no mercy
     if [ $(( `date +%s` - $processedAt )) -gt ${HBASE_STOP_TIMEOUT:-1200} ]; then
       break;
     fi
   done
  # process still there : kill -9
  if kill -0 $pidKilled > /dev/null 2>&1; then
    echo -n force stopping $commandName with kill -9 $pidKilled
    $JAVA_HOME/bin/jstack -l $pidKilled > "$logout" 2>&1
    kill -9 $pidKilled > /dev/null 2>&1
  fi
  # Add a CR after we're done w/ dots.
  echo
}
