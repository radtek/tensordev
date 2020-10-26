-- -----------------------------------------------------------------------------------
-- File Name    : rman_bkp_information_03.sql
-- Description  : Exibe o desempenho dos backups feitos via RMAN nos ultimos 30 dias.
--                OS dados serao obtidos a partir do controlfile.
--                É necessário estar logado na base com o usuário de backup.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_bkp_information_03.sql
-- Last Modified: 07/01/2013
-- -----------------------------------------------------------------------------------

ttitle cen    "DESEMPENHO DOS BACKUPS DOS ULTIMOS 30 DIAS" -
       skip 1 -
       cen    "==========================================" -
       skip 2

column data     format a18      heading "Data do backup"
column name     format a9       heading "Banco"
column tipo     format a12      heading "Tipo"
column ganho    format 990      heading "Ganho|(%)"
column taxa     format 990.0    heading "Taxa|(MB/s)"
column tam_arq  format 9,990.00 heading "Tamanho dos|arquivos (GB)"
column tam_blk  format 9,990.00 heading "Tamanho do|backup (GB)"
column duracao  format 9,990    heading "Duracao|(min)"

SELECT TO_CHAR(S.START_TIME, 'dd/mm/yy hh24:mi:ss') data,
       B.NAME,
       DECODE(S.BACKUP_TYPE, 'D', 'FULL', 'I', 'INCREMENTAL', 'L', 'ARCHIVE', '?') TIPO,
       D.TAM_ARQ/1024/1024/1024 TAM_ARQ,
       D.TAM_BLK/1024/1024/1024 TAM_BLK,
       (1-D.TAM_BLK/D.TAM_ARQ)*100 GANHO,
       (D.TAM_blk/S.ELAPSED_SECONDS)/1024/1024 TAXA,
       S.ELAPSED_SECONDS/60 duracao
from ( select SET_STAMP, SET_COUNT,
              SUM(DATAFILE_BLOCKS * block_size) TAM_ARQ,
              SUM(blocks * block_size) TAM_BLK
       from V$BACKUP_DATAFILE
       GROUP BY SET_STAMP, SET_COUNT
       UNION ALL
       select SET_STAMP, SET_COUNT,
              SUM(BLOCKS * block_size) TAM_ARQ,
              SUM(blocks * block_size) TAM_BLK
       from V$BACKUP_REDOLOG
       GROUP BY SET_STAMP, SET_COUNT ) D,
     ( select SET_STAMP, SET_COUNT, BACKUP_TYPE, START_TIME, ELAPSED_SECONDS
       from V$BACKUP_SET
       where START_TIME > sysdate - 31 ) S,
     V$DATABASE B
where S.SET_STAMP = D.SET_STAMP
  AND S.SET_COUNT = D.SET_COUNT
  AND ROUND(D.TAM_ARQ/1024/1024/1024,2) > 0
ORDER BY START_TIME
/

ttitle off
