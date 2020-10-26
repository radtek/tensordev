begin
  dbms_network_acl_admin.create_acl (
    acl => 'utl_mail.xml',
    description => 'Allow mail to be send',
    principal => 'SA',
    is_grant => TRUE,
    privilege => 'connect'
    );
    commit;
end;
/

begin
  dbms_network_acl_admin.add_privilege (
  acl => 'utl_mail.xml',
  principal => 'SA',
  is_grant => TRUE,
  privilege => 'resolve'
  );
  commit;
end;
/

begin
  dbms_network_acl_admin.assign_acl(
  acl => 'utl_mail.xml',
  host => '*'
  );
  commit;
end;
/
