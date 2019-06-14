define phone = '2'
select &phone from dual --where &phone=7
; 

WITH
    var AS
    (SELECT 'a' AS td FROM dual)
SELECT
    id
FROM
    tab_teste t,
    var
WHERE
   t.v2 = var.td;
    

select * from tab_teste;

WITH
    var as
    (select 'LTR'--$P{facility} 
        as id from DUAL)
SELECT
NULL AS CONTAINER,
NULL AS GKEY,
NULL AS GKEY_UFV,
NULL AS FACILITY
FROM
sparcsn4.inv_unit_fcy_visit
WHERE
2=1
union
select
unit.id,
unit.gkey,
ufv.gkey,
af.id
from
sparcsn4.inv_unit  unit
,sparcsn4.inv_unit_fcy_visit ufv
,sparcsn4.argo_facility af
,var
where
unit.gkey = ufv.unit_gkey
and af.gkey = ufv.fcy_gkey
and af.id = var.id --'LTR'
and unit.ID = 'CAIU7620828'
and rownum <=50
order by
1 asc;