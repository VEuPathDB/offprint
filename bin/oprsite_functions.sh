source "${Bin}/oprcommon_functions.sh"

function usage() {
  echo
  echo "Usage:"
  echo "$this source_website"
}

function startup_checks {
  if [[ $# == 0 || ! "$1" =~ .org$ ]]; then
    usage
    exit 1
  fi
  
  if [[ ! -d "${OPR_HOME}" ]]; then
    errexit "${OPR_HOME} is not valid value for OPR_HOME."
  fi
  make_working_dir
}

function write_env_dot_file {
  local source_website="$1"
  local to_file="$2"
  sudo curl -L -f -sL "http://${source_website}/dashboard/xml/vmenv/value" -o "$to_file"
  [[ "$?" -eq "0" ]] || errexit "Unable to create '$to_file'." 
}
