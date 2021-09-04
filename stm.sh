#!/bin/bash -i
HOSTS="/etc/hosts"

#colour schemes
RED='\033[0;31m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'

MODE="$1"

setProfilePath() {
  if [ "$SHELL" = "bash" ]; then
    PROFILE_PATH=~/.bashrc
  else
    PROFILE_PATH=~/.zshrc
  fi
}

setAliasesMaybe() {
  isInFile=$(cat "$PROFILE_PATH" | grep -c "sudo -E stm.sh")
  if [ $isInFile -eq 0 ]; then
    shopt -s expand_aliases
    echo "export PATH=${PWD}:\$PATH" >> "$PROFILE_PATH"
    echo "alias $STOP_MADNESS_ALIAS='sudo -E stm.sh'" >> "$PROFILE_PATH"
    echo "alias $START_MADNESS_ALIAS='sudo -E stm.sh --sad'" >> "$PROFILE_PATH"
  fi

  if [ "$SHELL" = "bash" ]; then
    source $PROFILE_PATH
  else
    /bin/zsh
  fi
}

printMode() {
  if [ -z "$MODE" ]; then
    printf "\nRunning in ${RED}WORK ${WHITE}mode...\n\n"
  else
    CLEAN_MODE=`echo ${MODE} | sed 's/-//g' | tr a-z A-Z`
    printf "\n${WHITE}Running in ${RED}${CLEAN_MODE} ${WHITE}mode...\n\n"
  fi
}

checkIfCanEditHosts () {
  if [ ! -w $HOSTS ]; then
    printf "${RED}Can only edit $HOSTS file in sudo mode 🙊\n\n"
    exit 1
  fi
}

sourceEnvVariables() {
  if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
  fi
}

cleanUpHostFileEntries() {
  sed -i -e '/#stopping-the-madness$/d' $HOSTS
}


addBlockedEntriesToHosts() {
  for BLOCKED in $TO_BLOCK; do
    echo -e "127.0.0.1\twww.$BLOCKED\t#stopping-the-madness" >> $HOSTS
    printf "${YELLOW}${BLOCKED} ${RED}has been blocked! 🚫\n\n"
  done
}

flushCache() {
  dscacheutil -flushcache
}

stopTheMadnessMaybe() {
  if [[ "$MODE" != "--sad" ]]; then
    addBlockedEntriesToHosts
  else
    printf "Re-enabling the madness... 😡\n\n"
  fi

  printf "${WHITE}Flushing Cache for changes to take effect... 🧹\n\n"
  flushCache
}

printMode
sourceEnvVariables
checkIfCanEditHosts
setProfilePath
cleanUpHostFileEntries
stopTheMadnessMaybe
setAliasesMaybe
