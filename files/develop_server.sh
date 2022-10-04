#!/bin/bash
##
# This section should match your Makefile
##
PY=${PY:-python}
PELICAN=${PELICAN:-pelican}
PELICANOPTS=

BASEDIR=$(pwd)
INPUTDIR=$BASEDIR/content
OUTPUTDIR=$BASEDIR/output
CONFFILE=$BASEDIR/pelicanconf.py

###
# Don't change stuff below here unless you are sure
###

SRV_PID=$BASEDIR/srv.pid
PELICAN_PID=$BASEDIR/pelican.pid

function usage() {
  echo "usage: $0 (stop) (start) (restart)"
  echo "This starts Pelican in debug and reload mode and then launches"
  echo "an HTTP server to help site development. It doesn't read"
  echo "your Pelican settings, so if you edit any paths in your Makefile"
  echo "you will need to edit your settings as well."
  echo ""
  echo "usage: $0 generate"
  echo "This generates the website so that it can be published on"
  echo "the web server."
  exit 3
}

function alive() {
  kill -0 $1 >/dev/null 2>&1
}

function shut_down() {
  PID=$(cat $SRV_PID)
  if [[ $? -eq 0 ]]; then
    if alive $PID; then
      echo "Stopping HTTP server"
      kill $PID
    else
      echo "Stale PID, deleting"
    fi
    rm $SRV_PID
  else
    echo "HTTP server PIDFile not found"
  fi

  PID=$(cat $PELICAN_PID)
  if [[ $? -eq 0 ]]; then
    if alive $PID; then
      echo "Killing Pelican"
      kill $PID
    else
      echo "Stale PID, deleting"
    fi
    rm $PELICAN_PID
  else
    echo "Pelican PIDFile not found"
  fi
}

function start_up() {
  local port="8000"
  echo "Starting up Pelican and HTTP server"
  cd $BASEDIR;
  $PELICAN --debug --autoreload $INPUTDIR -o $OUTPUTDIR -s $CONFFILE $PELICANOPTS &
  pelican_pid=$!
  echo $pelican_pid > $PELICAN_PID
  if ! alive $pelican_pid ; then
    echo "Pelican didn't start. Is the Pelican package installed?"
    return 1
  fi
  cd $OUTPUTDIR;
  $PY -m pelican.server $port
  srv_pid=$!
  echo $srv_pid > $SRV_PID
  if ! alive $srv_pid ; then
    echo "The HTTP server didn't start. Is there another service using port" $port "?"
    return 1
  fi
  sleep 1
  echo 'Exiting Pelican and HTTP server processes.'
}

function generate() {
  echo "Generating the website for publication on the actual webserver."
  rm -rf $OUTPUTDIR
  cd $BASEDIR;
  $PELICAN --debug $INPUTDIR -o $OUTPUTDIR -s $CONFFILE --ignore-cache $PELICANOPTS
  echo "Finished"
}

###
#  MAIN
###
[[ ($# -eq 0) || ($# -gt 1) ]] && usage

if [[ $1 == "stop" ]]; then
  shut_down
elif [[ $1 == "restart" ]]; then
  shut_down
  start_up
elif [[ $1 == "start" ]]; then
  if ! start_up; then
    shut_down
  fi
elif [[ $1 == "generate" ]]; then
  generate
else
  usage
fi
