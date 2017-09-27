-- Create database link from AppDB to AccountDB databases.

prompt Dropping existing database link, if any.;
set feedback off
set term off
WHENEVER SQLERROR CONTINUE NONE;
DROP PUBLIC DATABASE LINK vm.acctdb;


set feedback off
set pagesize 0
-- don't show variable substituions which will expose password
set verify off

set term on
prompt Creating new public database link to &1.

-- sqlerror does not exit with term on
set term off

WHENEVER SQLERROR EXIT FAILURE

CREATE PUBLIC DATABASE LINK vm.acctdb 
   CONNECT TO &2 IDENTIFIED BY &3
   USING '&1';

set term on
prompt Create link OK
prompt Testing new database link

set term off
SELECT 'OK' as test FROM DUAL@vm.acctdb;

set term on
prompt Test link OK

exit;
