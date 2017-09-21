set verify off

ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

-- TODO: review these create/alter tablespaces; should this be taken
-- care of by dbca + ebrc_savm_database.dbt when the db is created?

create bigfile tablespace APIDB datafile '/u02/oradata/&&oracleSid./apidb.dbf' size 100M autoextend on; 
-- The GUS tablespace is currently included by dbca + ebrc_savm_database.dbt
-- create bigfile tablespace GUS datafile '/u02/oradata/&&oracleSid./gus.dbf' size 100M autoextend on;
-- create bigfile tablespace INDX datafile '/u02/oradata/&&oracleSid./indx.dbf' size 100M autoextend on;

alter database default tablespace gus;

drop tablespace users including contents and datafiles cascade constraints;
create bigfile tablespace users datafile '/u02/oradata/&&oracleSid./users01.dbf' size 100M autoextend on;

alter database default tablespace users;

create role GUS_R;
create role GUS_W;
create role GUS_DBA;

-- reapply grants that are lost on network imports
GRANT SELECT_CATALOG_ROLE TO GUS_R;
