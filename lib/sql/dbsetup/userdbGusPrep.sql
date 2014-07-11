set verify off

ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

create tablespace GUS datafile '/u02/oradata/&&oracleSid./gus01.dbf' size 100M autoextend on maxsize unlimited;

create role GUS_R;
create role GUS_W;
create role GUS_DBA;

