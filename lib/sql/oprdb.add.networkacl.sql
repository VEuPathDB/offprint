-- ACL needed for /dashboard
-- Requires sysdba, e.g.
--     sqlplus sys/xxxx@userdb as sysdba
-- Based on 
--    https://mango.ctegd.uga.edu/svn/ApiCommonSystem/trunk/Oracle/sql/acl_upenn.sql
-- and
--    https://mango.ctegd.uga.edu/svn/ApiCommonSystem/trunk/Oracle/sql/add_acl_ToUsers_11203.sql

DEFINE acluser=&1

DECLARE
        ACL_PATH  VARCHAR2(32767);
     BEGIN

        -- Look for the ACL currently assigned to '*' and give GUS_R
        -- the "resolve" privilege if GUS_R does not have the privilege yet

        SELECT ACL INTO ACL_PATH FROM DBA_NETWORK_ACLS
        WHERE HOST = '*' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;

dbms_output.put_line('acl_path = '|| acl_path);
        dbms_output.put_line('ACL already Exists. Checks for Privilege and add the Privilege');

    IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(ACL_PATH,'GUS_R','connect')
        IS NULL THEN
      DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL_PATH,'GUS_R', TRUE, 'connect');
    END IF;

    EXCEPTION
    -- When no ACL has been assigned to '*'
    WHEN NO_DATA_FOUND THEN

        dbms_output.put_line('GUS_R does not have privilege, create ACL now');

        DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('users.xml',
           'ACL that lets GUS_R to use the UTL Package',
           'GUS_R', TRUE, 'connect');

        dbms_output.put_line('GUS_R does not have privilege, assign ACL now');

        DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('users.xml','*');

    END;
 /

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
   acl          => 'users.xml',
   principal    => 'GUS_R',
   is_grant     =>  TRUE,
   privilege    => 'resolve',
   position     =>  null);
 END;
 /

BEGIN DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
    acl     => 'users.xml',
    host    => '*.pcbi.upenn.edu');
END;
/


grant execute on utl_inaddr to &&acluser;                                      

BEGIN DBMS_NETWORK_ACL_ADMIN.add_privilege (                                    
   acl => 'users.xml',                                                            
   principal => UPPER('&&acluser'),                                                     
   is_grant => TRUE,                                                              
   privilege => 'resolve'); end;                                                  
/
