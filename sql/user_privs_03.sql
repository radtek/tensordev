-- -----------------------------------------------------------------------------------
-- File Name    : user_privs_03.sql
-- Description  : Todos os priviégios cadastrados na base de dados
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_privs_03.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select *
  from (SELECT 'grant ' || privilege || ' on ' || OWNER || '.' || table_name ||
               ' to ' || grantee || ';' s
          FROM dba_tab_privs
         WHERE grantee not in ('SYSTEM', 'SYS')
           and owner not in ('SYSTEM',
                             'SYS',
                             'CTXSYS',
                             'SYSMAN',
                             'OUTLN',
                             'OLAPSYS',
                             'ORDPLUGINS',
                             'DMSYS',
                             'MDSYS',
                             'MDDATA',
                             'WMSYS',
                             'WKSYS',
                             'SCOTT',
                             'DBSNMP')
        UNION ALL
        SELECT 'grant ' || privilege || ' to ' || grantee || ';' s
          FROM dba_sys_privs
         WHERE grantee not in ('SYSTEM',
                               'SYS',
                               'CTXSYS',
                               'SYSMAN',
                               'OUTLN',
                               'OLAPSYS',
                               'ORDPLUGINS',
                               'DMSYS',
                               'MDSYS',
                               'MDDATA',
                               'WMSYS',
                               'WKSYS',
                               'SCOTT',
                               'DBSNMP')
        UNION ALL
        select 'grant '||privilege||' on '||owner||'.'||table_name||
       '('||column_name||') '
        from   sys.dba_col_privs
         WHERE grantee not in ('SYSTEM',
                               'SYS',
                               'CTXSYS',
                               'SYSMAN',
                               'OUTLN',
                               'OLAPSYS',
                               'ORDPLUGINS',
                               'DMSYS',
                               'MDSYS',
                               'MDDATA',
                               'WMSYS',
                               'WKSYS',
                               'SCOTT',
                               'DBSNMP')
          UNION ALL                     
        SELECT 'grant ' || granted_role || ' to ' || grantee || ';' s
          FROM dba_role_privs
         WHERE grantee not in ('SYSTEM',
                               'SYS',
                               'CTXSYS',
                               'SYSMAN',
                               'OUTLN',
                               'OLAPSYS',
                               'ORDPLUGINS',
                               'DMSYS',
                               'MDSYS',
                               'MDDATA',
                               'WMSYS',
                               'WKSYS',
                               'SCOTT',
                               'DBSNMP') );
