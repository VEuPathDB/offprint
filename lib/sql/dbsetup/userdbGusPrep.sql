set verify off

ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

-- Thes users are required to receive grants
-- applied during import. Todo: understand
-- why this is. Is this an artifact of 
-- naked grants assigned to users instead 
-- of assigning a role?
CREATE USER UGA_FED IDENTIFIED BY xxxxxxxx;
CREATE USER WDKMAINT2 IDENTIFIED BY xxxxxxxx;
CREATE USER PLASMODBWWW IDENTIFIED BY xxxxxxxx;
CREATE USER TOXODBWWW IDENTIFIED BY xxxxxxxx;
CREATE USER WDKUSER IDENTIFIED BY xxxxxxxx;


-- The GUS tablespace is currently included by dbca + ebrc_savm_database.dbt
-- create tablespace GUS datafile '/u02/oradata/&&oracleSid./gus01.dbf' size 100M autoextend on maxsize unlimited;

create role GUS_R;
create role GUS_W;
create role GUS_DBA;
create role USERDB_LINK;
create role COMM_WDK_W;

-- reapply grants that are lost on network imports
GRANT SELECT_CATALOG_ROLE TO COMM_WDK_W;
