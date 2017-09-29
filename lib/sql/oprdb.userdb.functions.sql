set feedback off

prompt Installing UserDB functions.

set term off
WHENEVER SQLERROR EXIT FAILURE

create or replace package system.vm_impdp_remap
as
  function sanitize_userlogins_email(email varchar2) return VARCHAR2;
end;
/
create or replace package body system.vm_impdp_remap 
as

  function sanitize_userlogins_email(email varchar2) return VARCHAR2 is
    begin
      return CONCAT('NA@', SYS_GUID());
    end sanitize_userlogins_email;

  end vm_impdp_remap;
/

set term on
prompt UserDB functions installed.

exit;
