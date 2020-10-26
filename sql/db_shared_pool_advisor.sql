-- -----------------------------------------------------------------------------------
-- File Name    : db_shared_pool_advisor.sql
-- Description  : Arranging Shared Pool Size, this script shows if it's necessary to 
--                adjust the shared_pool
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_shared_pool_advisor.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
  prompt         ========================= 
  prompt         LIBRARY CACHE MISS RATIO
  prompt         ========================= 
  prompt (Caso o Rateio seja > 1 será necessário incrementar a shared_pool_size in init.ora)
  prompt
  column "LIBRARY CACHE MISS RATIO" format 99.9999
  column "executions"    format 999,999,999
  column "Cache misses while executing"    format 999,999,999
  select sum(pins) "executions", sum(reloads) "Cache misses while executing",
      (((sum(reloads)/sum(pins)))) "LIBRARY CACHE MISS RATIO"
  from v$librarycache; 
   
  prompt
  prompt         ========================= 
  prompt          Library Cache Section
  prompt         ========================= 
  prompt hit ratio should be > 70, and pin ratio > 70  estes resultados devem ser maiores que 70
  prompt caso contrario voce deve incrementar o tamanho da shared_pool_size

  column "reloads" format 999,999,999
  select namespace, trunc(gethitratio * 100) "Hit ratio",
  trunc(pinhitratio * 100) "pin hit ratio", reloads "reloads"
  from v$librarycache;
