-- -----------------------------------------------------------------------------------
-- File Name    : table_skip_corrupted_blocks.sql
-- Description  : Colocando a tabela habilitada para dar skip em blocos corrompidos
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_skip_corrupted_blocks.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
BEGIN
DBMS_REPAIR.SKIP_CORRUPT_BLOCKS(
SCHEMA_NAME => 'SCHEMA_NAME',
OBJECT_NAME => 'TABLE_NAME',
OBJECT_TYPE => DBMS_REPAIR.TABLE_OBJECT,
FLAGS => DBMS_REPAIR.SKIP_FLAG
);
END;
/
