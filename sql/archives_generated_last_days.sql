-- -----------------------------------------------------------------------------------
-- File Name    : archives_generated_last_days.sql
-- Description  : Arquives gerados nos ultimos dias
-- Requirements : Access to the DBA views.
-- Call Syntax  : @archives_generated_last_days.sql
-- Last Modified: 19/02/2019
-- -----------------------------------------------------------------------------------

SET LINES 180 PAGES 5000 COLSEP |

with
Q1 as (
  select ROWNUM RN, q1a.LH_DATE
    from (select distinct trunc (q1b.FIRST_TIME) LH_DATE
            from V$LOG_HISTORY q1b
           order by trunc (q1b.FIRST_TIME) desc) q1a
   where ROWNUM <= 9
),
Q2 as (
  select ROWNUM - 1 HN
    from DBA_OBJECTS
   where ROWNUM <= 24
),
Q3 as (
  select trunc (q3a.FIRST_TIME) LH_DATE, to_char (q3a.FIRST_TIME, 'HH24') LH_HN,
         nvl (q3b.BLOCKS * q3b.BLOCK_SIZE + 1024, 2048) LH_SZ
    from V$LOG_HISTORY q3a,
         V$ARCHIVED_LOG q3b
   where q3a.THREAD# = q3b.THREAD#
     and q3a.SEQUENCE# = q3b.SEQUENCE#
)
select lpad (C1, max (length (C1)) over (), C0P) ||' = ['||
       replace (lpad (C2, max (length (C2)) over (), C0P), ' 0M', '   ') ||'|'||
       replace (lpad (C3, max (length (C3)) over (), C0P), ' 0M', '   ') ||'|'||
       replace (lpad (C4, max (length (C4)) over (), C0P), ' 0M', '   ') ||'|'||
       replace (lpad (C5, max (length (C5)) over (), C0P), ' 0M', '   ') ||'|'||
       replace (lpad (C6, max (length (C6)) over (), C0P), ' 0M', '   ') ||'|'||
       replace (lpad (C7, max (length (C7)) over (), C0P), ' 0M', '   ') ||'|'||
       replace (lpad (C8, max (length (C8)) over (), C0P), ' 0M', '   ') ||'|'||
       replace (lpad (C9, max (length (C9)) over (), C0P), ' 0M', '   ') ||'|'||
       replace (lpad (C10, max (length (C10)) over (), C0P), ' 0M', '   ') ||']'
from (
  (select 0 C0O, ' ' C0P, 'HH' C1,
          nvl (to_char (max (case when a.RN = 9 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C2,
          nvl (to_char (max (case when a.RN = 8 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C3,
          nvl (to_char (max (case when a.RN = 7 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C4,
          nvl (to_char (max (case when a.RN = 6 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C5,
          nvl (to_char (max (case when a.RN = 5 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C6,
          nvl (to_char (max (case when a.RN = 4 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C7,
          nvl (to_char (max (case when a.RN = 3 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C8,
          nvl (to_char (max (case when a.RN = 2 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C9,
          nvl (to_char (max (case when a.RN = 1 then a.LH_DATE else null end), ' DDMon '), '00Zzz') C10
     from Q1 a
    union all
   select 1 C0O, '-' C0P, '-' C1, '-' C2, '-' C3, '-' C4, '-' C5, '-' C6, '-' C7, '-' C8, '-' C9, '-' C10
     from dual
    union all
   select 26 C0O, '-' C0P, '-' C1, '-' C2, '-' C3, '-' C4, '-' C5, '-' C6, '-' C7, '-' C8, '-' C9, '-' C10
     from dual
    union all
   select 27 C0O, ' ' C0P, 'DD' C1,
          ' '|| to_char (sum (case when q1.RN = 9 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C2,
          ' '|| to_char (sum (case when q1.RN = 8 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C3,
          ' '|| to_char (sum (case when q1.RN = 7 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C4,
          ' '|| to_char (sum (case when q1.RN = 6 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C5,
          ' '|| to_char (sum (case when q1.RN = 5 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C6,
          ' '|| to_char (sum (case when q1.RN = 4 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C7,
          ' '|| to_char (sum (case when q1.RN = 3 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C8,
          ' '|| to_char (sum (case when q1.RN = 2 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C9,
          ' '|| to_char (sum (case when q1.RN = 1 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C10
     from Q1 q1,
          Q3 q3
    where q3.LH_DATE = q1.LH_DATE)
union all
  (select 2 + q3.LH_HN C0O, ' ' C0P, to_char (q3.LH_HN, 'FM00') C1,
          ' '|| to_char (sum (case when q1.RN = 9 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C2,
          ' '|| to_char (sum (case when q1.RN = 8 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C3,
          ' '|| to_char (sum (case when q1.RN = 7 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C4,
          ' '|| to_char (sum (case when q1.RN = 6 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C5,
          ' '|| to_char (sum (case when q1.RN = 5 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C6,
          ' '|| to_char (sum (case when q1.RN = 4 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C7,
          ' '|| to_char (sum (case when q1.RN = 3 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C8,
          ' '|| to_char (sum (case when q1.RN = 2 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C9,
          ' '|| to_char (sum (case when q1.RN = 1 then q3.LH_SZ else 0 end) / 1048576, 'FM999G999G990')||'M' C10
     from Q1 q1,
          Q2 q2,
          Q3 q3
    where q3.LH_DATE = q1.LH_DATE
      and q3.LH_HN = to_char (q2.HN, 'FM00')
    group by (q3.LH_HN))
) where (C0O = 0 or upper (C1 ||' '|| C2 ||' '|| C3 ||' '|| C4 ||' '|| C5 ||' '|| C6 ||' '||
         C7 ||' '|| C8 ||' '|| C9) like upper ('%&___SEARCH___%'))
order by C0O;
