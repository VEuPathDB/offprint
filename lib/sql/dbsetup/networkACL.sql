-- ACL needed for /dashboard to run
--    select UTL_INADDR.get_host_name as server_name, UTL_INADDR.get_host_address as server_ip from dual
-- Must be installed by sysdba, e.g.
--     sqlplus sys/xxxx@userdb as sysdba

DEFINE acluser=&1

BEGIN

    DBMS_NETWORK_ACL_ADMIN.drop_acl('users.xml');
    EXCEPTION
      WHEN DBMS_NETWORK_ACL_ADMIN.acl_not_found
      THEN NULL;  -- It didn't exist, that's ok

    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(
      acl         => 'users.xml',
      description => 'ACL that lets GUS_R to use the UTL Package',
      principal   => 'GUS_R',
      is_grant    => TRUE,
      privilege   => 'resolve'
    );

    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('users.xml','*');

END;
/

-- BEGIN
--    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
--    acl          => 'users.xml',
--    principal    => 'GUS_R',
--    is_grant     =>  TRUE,
--    privilege    => 'resolve',
--    position     =>  null);
--  END;
--  /

BEGIN DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
    acl     => 'users.xml',
    host    => '*');
END;
/


