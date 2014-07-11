set verify off

DEFINE scriptPath=&1
DEFINE sysPassword=&2
DEFINE systemPassword=&2
DEFINE sysmanPassword=&2
DEFINE dbsnmpPassword=&2
DEFINE oracleSid=&3

host /u01/app/oracle/product/11.2.0.3/db_1/bin/orapwd password=&&sysPassword file=/u01/app/oracle/product/11.2.0.3/db_1/dbs/orapw&&oracleSid force=y

@&&scriptPath/CloneRmanRestore.sql
@&&scriptPath/cloneDBCreation.sql
@&&scriptPath/postScripts.sql
@&&scriptPath/lockAccount.sql
@&&scriptPath/postDBCreation.sql
@&&scriptPath/&&oracleSid.GusPrep.sql
@&&scriptPath/networkACL.sql

exit;