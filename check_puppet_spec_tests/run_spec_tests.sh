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
  exit 0
}

syserr() {
  echo "$0: ERROR: $*" 1>&2
  exit 1
}

## No arguments
if [[ ${#*} -eq 0 ]]; then
  _help
fi

case "$1" in
	full)            ACTION="rake spec";;
	prep)            ACTION="rake spec_prep";;
	clean)           ACTION="rake spec_clean";;
	-h|--help)       _help;;
	*)               syserr "Command option '$1' not recognized";;
esac

# Set PUPPET_ROOT to $2 or /etc/puppet
#
PUPPET_ROOT=${2:-/etc/puppet}

# Include each folder which has a spec folder which is not empty.
#
unset MODULE_FOLDERS_WITH_SPECS
while read path; do
  if [[ $(/bin/ls -1 "$path" | wc -l) -ne 0 ]]; then
    MODULE_FOLDERS_WITH_SPECS+=("$(dirname "$path")")
  fi
done < <(find ${PUPPET_ROOT} -type d -name spec -print)

# Leave early if there's nothing to do.
#
if [[ ${#MODULE_FOLDERS_WITH_SPECS} -eq 0 ]]; then
  echo "No specs were found."
  exit 0
fi

# Run each test, collecting failures.
#
unset MODULES_FAILING
for module in "${MODULE_FOLDERS_WITH_SPECS[@]}"; do
  module_name=${module#$PUPPET_ROOT}

  pushd "${module}" >/dev/null
  echo "The current module is ${module_name}..."
  if ! ${ACTION}; then
    MODULES_FAILING+=("${module_name}")
  fi
  popd >/dev/null

done

# Complain noisily if there were problems.
#
if [[ ${#MODULES_FAILING} -ne 0 ]]; then
  echo "The following modules had errors:"
  for module in "${MODULES_FAILING[@]}"; do
    echo "  $module"
  done
  exit 1
fi
