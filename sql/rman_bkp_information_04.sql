-- -----------------------------------------------------------------------------------
-- File Name    : rman_bkp_information_04.sql
-- Description  : Exibe o desempenho dos backups feitos via RMAN nos ultimos 30 dias.
--                Os dados serao obitidos a partir do dicionario do catalogo.
--                É necessário estar logado no Catálogo com o usuário de backup.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_bkp_information_04.sql
-- Last Modified: 10/04/2014
-- -----------------------------------------------------------------------------------

set pages 10000 lines 90

ttitle cen    "DESEMPENHO DOS BACKUPS DOS ULTIMOS 30 DIAS" -
       skip 1 -
       cen    "==========================================" -
       skip 2

column data     heading "Data do backup"
column name     heading "Banco"
column tipo     heading "Tipo"

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
from ( select DB_KEY,
              SET_STAMP, SET_COUNT,
              SUM(DATAFILE_BLOCKS * block_size) TAM_ARQ,
              SUM(blocks * block_size) TAM_BLK
       from RC_BACKUP_DATAFILE
       GROUP BY DB_KEY, SET_STAMP, SET_COUNT
       UNION ALL
       select DB_KEY,
              SET_STAMP, SET_COUNT,
              SUM(BLOCKS * block_size) TAM_ARQ,
              SUM(blocks * block_size) TAM_BLK
       from RC_BACKUP_REDOLOG
       GROUP BY DB_KEY, SET_STAMP, SET_COUNT ) D,
       ( select DB_KEY, SET_STAMP, SET_COUNT, BACKUP_TYPE, START_TIME, ELAPSED_SECONDS
         from RC_BACKUP_SET
         where START_TIME > sysdate - 31 ) S,
       RC_DATABASE B
where D.DB_KEY = S.DB_KEY
  AND D.SET_STAMP = S.SET_STAMP
  AND D.SET_COUNT = S.SET_COUNT
  AND D.DB_KEY = B.DB_KEY
  AND ROUND(D.TAM_ARQ/1024/1024/1024,2) > 0
ORDER BY START_TIME
/
