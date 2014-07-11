SET VERIFY OFF
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /u01/app/oracle/admin/&&oracleSid./log/cloneDBCreation.log append
Create controlfile reuse set database "&&oracleSid"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
Datafile 
'/u02/oradata/&&oracleSid./system01.dbf',
'/u02/oradata/&&oracleSid./sysaux01.dbf',
'/u02/oradata/&&oracleSid./undotbs01.dbf',
'/u02/oradata/&&oracleSid./users01.dbf'
LOGFILE GROUP 1 ('/u02/oradata/&&oracleSid./redo01.log') SIZE 51200K,
GROUP 2 ('/u02/oradata/&&oracleSid./redo02.log') SIZE 51200K,
GROUP 3 ('/u02/oradata/&&oracleSid./redo03.log') SIZE 51200K RESETLOGS;
exec dbms_backup_restore.zerodbid(0);
shutdown immediate;
startup nomount pfile="&&scriptPath/init&&oracleSid.Temp.ora";
Create controlfile reuse set database "&&oracleSid"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
Datafile 
'/u02/oradata/&&oracleSid./system01.dbf',
'/u02/oradata/&&oracleSid./sysaux01.dbf',
'/u02/oradata/&&oracleSid./undotbs01.dbf',
'/u02/oradata/&&oracleSid./users01.dbf'
LOGFILE GROUP 1 ('/u02/oradata/&&oracleSid./redo01.log') SIZE 51200K,
GROUP 2 ('/u02/oradata/&&oracleSid./redo02.log') SIZE 51200K,
GROUP 3 ('/u02/oradata/&&oracleSid./redo03.log') SIZE 51200K RESETLOGS;
alter system enable restricted session;
alter database "&&oracleSid" open resetlogs;
exec dbms_service.delete_service('seeddata');
exec dbms_service.delete_service('seeddataXDB');
alter database rename global_name to "&&oracleSid..apidb.org";
ALTER TABLESPACE TEMP ADD TEMPFILE '/u02/oradata/&&oracleSid./temp01.dbf' SIZE 20480K REUSE AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED;
select tablespace_name from dba_tablespaces where tablespace_name='USERS';
select sid, program, serial#, username from v$session;
alter database character set INTERNAL_CONVERT WE8MSWIN1252;
alter database national character set INTERNAL_CONVERT AL16UTF16;
alter user sys account unlock identified by "&&sysPassword";
alter user system account unlock identified by "&&systemPassword";
alter system disable restricted session;
