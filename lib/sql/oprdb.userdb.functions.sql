set feedback off

prompt Installing UserDB functions.

set term off
WHENEVER SQLERROR EXIT FAILURE

create or replace package system.vm_impdp_remap
as
  function sanitize_userlogins_password(passwd varchar2) return VARCHAR2;
  function sanitize_userlogins_email(email varchar2) return VARCHAR2;
  function sanitize_userlogins_address(address varchar2) return VARCHAR2;
  function sanitize_userlogins_phone(phone_number varchar2) return VARCHAR2;
end;
/
create or replace package body system.vm_impdp_remap 
as

  function sanitize_userlogins_password(passwd varchar2) return VARCHAR2 is
    begin
      return SYS_GUID();
    end sanitize_userlogins_password;

  function sanitize_userlogins_email(email varchar2) return VARCHAR2 is
    begin
      return CONCAT('NA@', SYS_GUID());
    end sanitize_userlogins_email;

  function sanitize_userlogins_address(address varchar2) return VARCHAR2 is
    begin
      return 'NA';
    end sanitize_userlogins_address;

  function sanitize_userlogins_phone(phone_number varchar2) return VARCHAR2 is
    begin
      return 'NA';
    end sanitize_userlogins_phone;

  end vm_impdp_remap;
/

set term on
prompt UserDB functions installed.

exit;