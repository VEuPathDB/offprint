DEFINE dblink=&1

prompt Dropping existing '&&dblink' database link, if any.;
set feedback off
set term off
whenever sqlerror continue none;
DROP PUBLIC DATABASE LINK &&dblink;

set term on
prompt Link drop OK
exit;
