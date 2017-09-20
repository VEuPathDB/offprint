create or replace package system.vm_impdp_remap
as
  function sanitize_accounts_password(passwd varchar2) return VARCHAR2;
  /* 30char limit on function names in 11g */
  function sanitize_account_prop_value(value varchar2) return VARCHAR2;
end;
/
create or replace package body system.vm_impdp_remap 
as

  function sanitize_accounts_password(passwd varchar2) return VARCHAR2 is
    begin
      return 'sanitized, yo';
    end sanitize_accounts_password;

  function sanitize_account_prop_value(value varchar2) return VARCHAR2 is
    begin
      return 'NA';
    end sanitize_account_prop_value;

  end vm_impdp_remap;
/
