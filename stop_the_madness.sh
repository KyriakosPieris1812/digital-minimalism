#!/bin/bash

let "STOP_THE_MADNESS_SECONDS=$1 * 1"
let "START_THE_MADNESS_SECONDS=$2 * 1"
let REPEATS=$3

readonly LOCALHOST="127.0.0.1"
readonly HOSTS_FILE=/etc/hosts
readonly HOSTS_BACKUP_FILE=/etc/hosts.bk
readonly HOSTS_SWAP_FILE=/etc/hosts.swap

function create_blocked_hostnames() {
  make_backup
  echo "# Digital Minimalism" >> $HOSTS_BACKUP_FILE
  while read -r entry
  do
    echo "${LOCALHOST} ${entry}" >> $HOSTS_BACKUP_FILE
  done < digital_minimalism.txt
}

function make_backup() {
  cp $HOSTS_FILE $HOSTS_BACKUP_FILE
}

function swap_hostnames() {
 mv $HOSTS_FILE $HOSTS_SWAP_FILE &&
  mv $HOSTS_BACKUP_FILE $HOSTS_FILE &&
    mv $HOSTS_SWAP_FILE $HOSTS_BACKUP_FILE
}

function remove_blocked_hostnames() {
  rm $HOSTS_BACKUP_FILE
}

function notifyEndOfMadness() {
  osascript -e "display notification \"Round:$1\" with title \"Stopping the madness\" sound name \"Submarine\""
}

function notifyStartOfMadness() {
  osascript -e "display notification \"Round:$1\" with title \"Starting the madness\" sound name \"Tink\""
}

function applyDigitalMinimalism() {
  for i in `seq $REPEATS`
  do
    swap_hostnames && notifyEndOfMadness $i && sleep $STOP_THE_MADNESS_SECONDS
    swap_hostnames && notifyStartOfMadness $i && sleep $START_THE_MADNESS_SECONDS
  done
}

create_blocked_hostnames
applyDigitalMinimalism
remove_blocked_hostnames