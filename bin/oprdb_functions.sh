source "${Bin}/oprcommon_functions.sh"


function usage() {
  echo
  echo "Usage:"
  echo "${this} source_website"
}



function delete_database {
  local dest_database="$1"
  sudo -u oracle -E -P "${OPR_HOME}/bin/delete_database" "${dest_database}"
}

function create_empty_database {
  local dest_database="$1"
  local dest_domain="$2"
  local dest_passwd="$3"
  local dbca_template="$4"
  sudo -u oracle -E -P "${OPR_HOME}/bin/create_empty_database" "${dest_database}" "${dest_domain}" "${dest_passwd}" "${dbca_template}"
}

# return first alias name found for database
function source_db_alias {
  local source_website=$1
  local type=$2  # userdb or acctdb or appdb
  local url="http://${source_website}/dashboard/xml/wdk/databases/${type}/aliases/alias/value"
  local dbalias
  dbalias="$(curl -L -f -s $url)" \
    || errexit "Unable to lookup database alias from '${url}'"
  echo $dbalias
}

# Return descriptor of form
# (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=medlar.rcc.uga.edu)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=rm15873.uga.edu)))
function source_db_descriptor {
  local source_website=$1
  local type=$2  # userdb or acctdb or appdb

  local source_host_name
  source_host_name="$(curl -L -f -s ${SOURCE_WEBSITE}/dashboard/xml/wdk/databases/${type}/servername/value)" \
    || errexit "Unable to lookup database host from '${url}'"

  local source_service_name
  source_service_name="$(curl -L -f -s ${SOURCE_WEBSITE}/dashboard/xml/wdk/databases/${type}/servicename/value)" \
    || errexit "Unable to lookup database service_name from '${url}'"

  local source_db="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${source_host_name})(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=${source_service_name})))"

  echo $source_db
}


function userdb_schema_list {
  local user_schema=$1
  local schemas=''  
  while read line; do
    line=${line%%#*}  # strip comment (if any)

    local e
    eval e="${line}"
    e="$(echo $e | sed s/%%user_schema%%/${user_schema}/)"

    schemas="${schemas} $e"
  done < "${OPR_HOME}/conf/oprdb.userdb.schema"
  echo $schemas
}

function acctdb_schema_list {
  local acct_schema=$1
  local schemas=''  
  while read line; do
    line=${line%%#*}  # strip comment (if any)

    local e
    eval e="${line}"
    e="$(echo $e | sed s/%%account_schema%%/${account_schema}/)"

    schemas="${schemas} $e"
  done < "${OPR_HOME}/conf/oprdb.acctdb.schema"
  echo $schemas
}

function appdb_schema_list {
  local app_login_schema=$1
  local schemas=''  
  while read line; do
    line=${line%%#*}  # strip comment (if any)
    
    local e
    eval e="${line}"
    e="$(echo $e | sed "s/%%app_login_schema%%/${app_login_schema}/" )"

    schemas="${schemas} $e"
  done < "${OPR_HOME}/conf/oprdb.appdb.schema"
  echo $schemas
}

function userdb_export_queries {
  local user_schema=$1
  local queries='# Queries for selective row exports.'
  while read line; do
    line=${line%%#*}  # strip comment (if any)

    local e="${line}"
    e="$(echo $e | sed "s/%%user_schema%%/${user_schema}/g")"

    local queries
    queries="$(printf '%s\n%s' "${queries}" "$e")"

  done < "${OPR_HOME}/conf/oprdb.userdb.min.exp.query"
  echo "${queries}"
}

function acctdb_export_queries {
  local acct_schema=$1
  local queries='# Queries for selective row exports.'
  while read line; do
    line=${line%%#*}  # strip comment (if any)

    local e="${line}"
    e="$(echo $e | sed "s/%%account_schema%%/${account_schema}/g")"

    local queries
    queries="$(printf '%s\n%s' "${queries}" "$e")"

  done < "${OPR_HOME}/conf/oprdb.acctdb.min.exp.query"
  echo "${queries}"
}

function full_scrub_remap {
  local account_schema=$1
  local remap='# scrub user profile data'
  while read line; do
    line=${line%%#*}  # strip comment (if any)

    local e
    eval e="${line}"
    e="$(echo $e | sed "s/%%account_schema%%/${account_schema}/g")"

    local remap
    remap="$(printf '%s\n%s' "${remap}" "$e")"

  done < "${OPR_HOME}/conf/oprdb.fullscrub.remap"
  echo "${remap}"
}

function app_login_schema_name {
  local source_website="$1"
  local url="http://${source_website}/dashboard/xml/wdk/modelconfig/appdb/login/value"

  local app_login
  app_login="$(curl -L -f -s ${url} | sed  's/\.$//')" \
    || errexit "Unable to lookup database login from '${url}'."

  echo $app_login | tr '[:lower:]' '[:upper:]'
}

function user_schema_name {
  local source_website="$1"
  local url="http://${source_website}/dashboard/xml/wdk/modelconfig/userdb/userschema/value"
  
  local user_schema
  user_schema="$(curl -L -f -s ${url} | sed  's/\.$//')" \
    || errexit "Unable to lookup WDK user schema from '${url}'."

  echo $user_schema | tr '[:lower:]' '[:upper:]'
  return ${PIPESTATUS[0]}
}

function account_schema_name {
  local source_website="$1"
  local url="http://${source_website}/dashboard/xml/wdk/modelconfig/accountdb/accountschema/value"
  
  local account_schema
  account_schema="$(curl -L -f -s ${url} | sed  's/\.$//')" \
    || errexit "Unable to lookup WDK account schema from '${url}'."

  echo $account_schema | tr '[:lower:]' '[:upper:]'
  return ${PIPESTATUS[0]}
}


# Report the estimated size of the given database on filesystem.
# Not a good estimate of destination size if using query filter during exp/imp.
function database_size {
  local source_database="$1"
  local login="$2"
  local passwd="$3"

  local source_db_size
  source_db_size="$(cat <<'EOF' |
    set pagesize 0
    set feedback off
    select ROUND(
    ( select sum(bytes)/1024/1024/1024 data_size from dba_data_files ) +
    ( select nvl(sum(bytes),0)/1024/1024/1024 temp_size from dba_temp_files ) +
    ( select sum(bytes)/1024/1024/1024 redo_size from sys.v_$log ) +
    ( select sum(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024/1024 controlfile_size from v$controlfile)
    ) "Size in GB" from dual;
EOF
    sqlplus -S -L $login/$passwd@$source_database | awk '{print $source_database}'
  )"

  echo $source_db_size
}

function create_import_dblink {
  local dest_database="$1"
  local dest_account="$2"
  local dest_passwd="$3"
  local source_database="$4"
  local source_account="$5"
  local source_passwd="$6"
  local link_name="$7"
  sqlplus -S -L "${dest_account}/${dest_passwd}@${dest_database}" <<EOF
WHENEVER OSERROR EXIT FAILURE
@"${OPR_HOME}/lib/sql/oprdb.create.import.dblink.sql" "${source_database}" "${source_account}" "${source_passwd}" "${link_name}"
EOF
  [[ "$?" -eq "0" ]] || errexit "Unable to create functional import link." 
}

function create_userdb_dblink {
  local dest_database="$1"
  local dest_account="$2"
  local dest_passwd="$3"
  local source_database="$4"
  local source_account="$5"
  local source_passwd="$6"
  sqlplus -S -L "${dest_account}/${dest_passwd}@${dest_database}" <<EOF
WHENEVER OSERROR EXIT FAILURE
@"${OPR_HOME}/lib/sql/oprdb.create.userdb.dblink.sql" "${source_database}" "${source_account}" "${source_passwd}"
EOF
  [[ "$?" -eq "0" ]] || errexit "Unable to create functional userdb link." 
}

function create_acctdb_dblink {
  local dest_database="$1"
  local dest_account="$2"
  local dest_passwd="$3"
  local source_database="$4"
  local source_account="$5"
  local source_passwd="$6"
  sqlplus -S -L "${dest_account}/${dest_passwd}@${dest_database}" <<EOF
WHENEVER OSERROR EXIT FAILURE
@"${OPR_HOME}/lib/sql/oprdb.create.acctdb.dblink.sql" "${source_database}" "${source_account}" "${source_passwd}"
EOF
  [[ "$?" -eq "0" ]] || errexit "Unable to create functional acctdb link." 
}


function drop_import_dblink {
  local dest_database="$1"
  local dest_account="$2"
  local dest_passwd="$3"
  local link_name="$4"
  sqlplus -S -L "${dest_account}/${dest_passwd}@${dest_database}" <<EOF
WHENEVER OSERROR EXIT FAILURE
@"${OPR_HOME}/lib/sql/oprdb.drop.import.dblink.sql" "${link_name}"
EOF
  [[ "$?" -eq "0" ]] || errexit "Unable to drop import link." 
}

function create_acctdb_functions {
  local dest_database="$1"
  local dest_account="$2"
  local dest_passwd="$3"
  sqlplus -S -L "${dest_account}/${dest_passwd}@${dest_database}"  <<EOF
WHENEVER OSERROR EXIT FAILURE
@"${OPR_HOME}/lib/sql/oprdb.acctdb.functions.sql"
EOF
  [[ "$?" -eq "0" ]] || errexit "Unable to install AccountDB database functions." 
}

function add_wdk_user {
  # dest_account must be SYS (or someone who can auth 'as sysdba')
  local dest_database="$1"
  local dest_account="$2"
  local dest_passwd="$3"
  local wdk_user_login="$4"
  local wdk_user_password="$5"
  sqlplus -S -L "${dest_account}/${dest_passwd}@${dest_database}" as sysdba <<EOF
WHENEVER OSERROR EXIT FAILURE
@"${OPR_HOME}/lib/sql/oprdb.create.wdkuser.sql" "${wdk_user_login}" "${wdk_user_password}"
EOF
}
