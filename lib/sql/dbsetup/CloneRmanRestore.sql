SET VERIFY OFF
SET TERM on
SET ECHO on

connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /u01/app/oracle/admin/&&oracleSid./log/CloneRmanRestore.log append
startup nomount pfile="&&scriptPath./init&&oracleSid..ora";
@&&scriptPath./rmanRestoreDatafiles.sql;
spool off
