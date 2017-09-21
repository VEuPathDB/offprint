set verify off

ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

-- Thes users are required to receive grants
-- applied during import. Todo: understand
-- why this is. Is this an artifact of 
-- naked grants assigned to users instead 
-- of assigning a role?
CREATE USER UGA_FED IDENTIFIED BY xxxxxxxx;

create role APP_R;
create role USERACCTS_W;
create role USERACCTS_R;

-- GUS_R is used by networkACL.sql
create role GUS_R;

-- reapply grants that are lost on network imports
GRANT SELECT_CATALOG_ROLE TO APP_R;
