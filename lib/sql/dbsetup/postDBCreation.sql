SET VERIFY OFF
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /u01/app/oracle/admin/&&oracleSid./log/postDBCreation.log append
execute DBMS_AUTO_TASK_ADMIN.disable();
@/u01/app/oracle/product/11.2.0.3/db_1/rdbms/admin/catbundle.sql psu apply;
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute dbms_swrf_internal.cleanup_database(cleanup_local => FALSE);
commit;
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
create spfile='/u01/app/oracle/product/11.2.0.3/db_1/dbs/spfile&&oracleSid..ora' FROM pfile='&&scriptPath/init&&oracleSid..ora';
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup ;
host /u01/app/oracle/product/11.2.0.3/db_1/bin/emca -config dbcontrol db -silent -SYS_PWD &&sysPassword -DBSNMP_PWD &&sysPassword -SYSMAN_PWD &&sysPassword -DB_UNIQUE_NAME &&oracleSid. -PORT 1521 -EM_HOME /u01/app/oracle/product/11.2.0.3/db_1 -LISTENER LISTENER -SERVICE_NAME &&oracleSid..apidb.org -SID &&oracleSid. -ORACLE_HOME /u01/app/oracle/product/11.2.0.3/db_1 -HOST sa.apidb.org -LISTENER_OH /u01/app/oracle/product/11.2.0.3/db_1 -LOG_FILE /u01/app/oracle/admin/&&oracleSid./log/emConfig.log;
host /u01/app/oracle/product/11.2.0.3/db_1/bin/emctl stop dbconsole
spool off
