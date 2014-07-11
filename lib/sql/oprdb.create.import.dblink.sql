-- Create database link betwee source and destination databases.
-- Requires input paramter values for <source_database> <source login> <source password>
-- The source account requires EXP_FULL_DATABASE role.

DEFINE source_db=&1
DEFINE source_account=&2
DEFINE source_passwd=&3
DEFINE dblink=&4

prompt Dropping existing database link, if any.;
set feedback off
set term off
WHENEVER SQLERROR CONTINUE NONE;
DROP PUBLIC DATABASE LINK &&dblink;


set feedback off
set pagesize 0
-- don't show variable substituions which will expose password
set verify off

set term on
prompt Creating new public database link to &source_db.

-- sqlerror does not exit with term on
set term off

WHENEVER SQLERROR EXIT FAILURE

CREATE PUBLIC DATABASE LINK &&dblink 
   CONNECT TO &source_account IDENTIFIED BY &source_passwd
   USING '&source_db';

set term on
prompt Create link OK
prompt Testing new database link

set term off
SELECT 'OK' as test FROM DUAL@&&dblink;

set term on
prompt Test link OK

exit;
