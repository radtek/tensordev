-- -----------------------------------------------------------------------------------
-- File Name    : user_change_pass.sql
-- Description  : Monta comandos para alterar password do usuário.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_change_pass.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------

SELECT 'ALTER USER ' || USERNAME || ' IDENTIFIED BY ' || USERNAME || ';' ||
       CHR(10) || 'CONN ' || USERNAME || '/' || USERNAME || CHR(10) ||
       'ALTER USER ' || USERNAME || ' IDENTIFIED BY VALUES ''' || PASSWORD ||
       ''';'
  FROM DBA_USERS U, V$INSTANCE I
 WHERE USERNAME = UPPER('&USER');
