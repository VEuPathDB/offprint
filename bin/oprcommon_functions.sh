: ${OPR_HOME:="/opt/opr"}
: ${OPR_WD:="$HOME/.opr"}
: ${OPR_CONF:="$HOME/offprint.conf"}

function errexit {
  local msg
  [[ $# == 0 ]] && msg="at ${BASH_SOURCE[1]} line ${BASH_LINENO[0]}" || msg=$1
  echo "FATAL: $msg" 1>&2
	exit 1
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


function join { local IFS="$1"; shift; echo "$*"; }

function log {
  local msg
  [[ $# == 0 ]] && msg="at ${BASH_SOURCE[1]} line ${BASH_LINENO[0]}" || msg=$1
  ts="$(date '+%d/%h/%Y:%H:%M:%S')"
  echo "[$ts] $msg" 1>&2
}

function make_working_dir {
  mkdir -p "${OPR_WD}" \
    || errexit "Could not make working directory '${OPR_WD}'"
}
