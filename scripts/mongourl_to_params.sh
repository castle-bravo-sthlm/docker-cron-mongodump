#!/bin/bash

mongourl_to_params () {
  # extract the protocol
  proto="`echo $1 | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
  # remove the protocol
  url=`echo $1 | sed -e s,$proto,,g`

  # extract the user and password (if any)
  userpass="`echo $url | grep @ | cut -d@ -f1`"
  pass=`echo $userpass | grep : | cut -d: -f2`
  if [ -n "$pass" ]; then
      user=`echo $userpass | grep : | cut -d: -f1`
  else
      user=$userpass
  fi

  # extract the host -- updated
  hostport=`echo $url | sed -e s,$userpass@,,g | cut -d/ -f1`
  port=`echo $hostport | grep : | cut -d: -f2`
  if [ -n "$port" ]; then
      host=`echo $hostport | grep : | cut -d: -f1`
  else
      host=$hostport
  fi

  # extract the path (if any)
  db="`echo $url | grep / | cut -d/ -f2-`"
}
