#!/bin/sh

# Edited from inital broadway script in order to avoid error stream -- @benjaminherber

set -e

if [ "$BROADWAY" != "" ]; then
  export BROADWAY_DISPLAY=":$BROADWAY"
  if [ "$GDK_BACKEND" = "" ]; then
    export GDK_BACKEND="broadway"
  else
    if [ "$(echo "$GDK_BACKEND" | grep "broadway")" == "" ]; then
      export GDK_BACKEND="$GDK_BACKEND,broadway"
    fi
  fi
  # Check if an instance of broadwayd is already running in the same port
  #if [ "$(lsof -Pi :$((8080 + $BROADWAY)) -sTCP:LISTEN -Fc | grep broadwayd)" == "" ]; then
  set +e; curl localhost:$((8080 + $BROADWAY)) > /dev/null 2>&1; err="$?"; set -e
  if [ "$err" != "0" ]; then
    echo "BROADWAY_DISPLAY: $BROADWAY_DISPLAY"
    echo "GDK_BACKEND: $GDK_BACKEND"
    # Start broadway server
    broadwayd "$BROADWAY_DISPLAY" &> /dev/null &
  fi
fi

set +e