set feedback off

prompt Installing AccountDB functions.

set term off
WHENEVER SQLERROR EXIT FAILURE

create or replace package system.vm_impdp_remap
as
  function sanitize_accounts_password(passwd varchar2) return VARCHAR2;
  function sanitize_accounts_email(email varchar2) return VARCHAR2;
  function sanitize_accounts_address(address varchar2) return VARCHAR2;
  function sanitize_accounts_phone(phone_number varchar2) return VARCHAR2;
end;
/
create or replace package body system.vm_impdp_remap 
as

  function sanitize_accounts_password(passwd varchar2) return VARCHAR2 is
    begin
      return SYS_GUID();
    end sanitize_accounts_password;

  function sanitize_accounts_email(email varchar2) return VARCHAR2 is
    begin
      return CONCAT('NA@', SYS_GUID());
    end sanitize_accounts_email;

  function sanitize_accounts_address(address varchar2) return VARCHAR2 is
    begin
      return 'NA';
    end sanitize_accounts_address;

  function sanitize_accounts_phone(phone_number varchar2) return VARCHAR2 is
    begin
      return 'NA';
    end sanitize_accounts_phone;

  end vm_impdp_remap;
/

set term on
prompt UserDB functions installed.

exit;