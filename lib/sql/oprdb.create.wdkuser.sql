DEFINE user=&1
DEFINE passwd=&2

CREATE USER &&user IDENTIFIED BY &&passwd DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP;
ALTER USER &&user ACCOUNT UNLOCK;
GRANT CREATE SESSION TO &&user;
GRANT RESOURCE TO &&user;
ALTER USER &&user DEFAULT ROLE ALL;
ALTER USER &&user QUOTA UNLIMITED ON USERS;
ALTER USER &&user QUOTA UNLIMITED ON GUS;
GRANT GUS_R TO &&user;
GRANT GUS_W to &&user;


-- ACL used by EuPathDB /dashboard to run
--   select UTL_INADDR.get_host_name as server_name, UTL_INADDR.get_host_address as server_ip from dual;
-- (users.xml ACL must have already been created)
GRANT EXECUTE on utl_inaddr to &&user;                                      

BEGIN DBMS_NETWORK_ACL_ADMIN.add_privilege (                                    
   acl        => 'users.xml',                                                            
   principal  => UPPER('&&user'),                                                     
   is_grant   => TRUE,                                                              
   privilege  => 'resolve'); 
END;                                                  
/
