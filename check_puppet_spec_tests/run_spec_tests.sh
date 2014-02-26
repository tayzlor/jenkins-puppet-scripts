#!/bin/bash

_help() {
  cat <<EOHELP
USAGE: $0 <command> <folder> [...]
Run actions for rspec test for puppet modules.

COMMANDS:
  full                  Run spec tests in a clean fixtures directory for every module.
  prep                  Create the fixtures directory.
  clean                 Clean up the fixtures directory.

OPTIONS:
  -h, --help                  Display this message and exit.

The second argument should be a folder containing puppet modules.
Spec folders are searched recursively. Value by default is "/etc/puppet"

EOHELP
  exit 0;
}

syserr() {
  echo "$0: ERROR: $*" 1>&2
  exit 1;
}

## No arguments
if [ ${#*} == 0 ]; then
  _help
fi;

case "$1" in
	full)            ACTION="rake spec";;
	prep)            ACTION="rake spec_prep";;
	clean)           ACTION="rake spec_clean";;
	-h|--help)       _help;;
	*)               syserr "Command option '$1' not recognized";;
esac

PUPPET_ROOT="/etc/puppet";
[ -z $2 ] || PUPPET_ROOT=$2
MODULE_FOLDERS_WITH_SPECS=$(find ${PUPPET_ROOT} -type d -name spec -exec sh -c 'dirname {}' \;);
MODULES_FAILING=""
[ -z $2 ] || PUPPET_ROOT=$2

if [ -z "${MODULE_FOLDERS_WITH_SPECS}" ]; then
  echo "No specs were found."
  exit 0;
fi; 

for module in ${MODULE_FOLDERS_WITH_SPECS}; do

  error=0
  cd ${module}
  echo "The current module is ${module}..."
  ${ACTION} || error=1

  [ "$error" == "0" ] || MODULES_FAILING="${MODULES_FAILING}\n${module}"

done

if [ ! -z "${MODULES_FAILING}" ]; then
  echo -e "There were errors in the next modules: ${MODULES_FAILING}";
  exit 1;
fi
