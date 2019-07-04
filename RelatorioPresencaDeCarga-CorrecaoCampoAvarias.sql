select  
        cl.goods_gkey, cl.id , cdt.description
		--,listagg(cdt.description,'; ') within group (order by cdt.description) as avaria_cargo_lot
from
                    SPARCSN4PRD.crg_lots cl --on  ig.gkey = cl.goods_gkey
		inner join	SPARCSN4PRD.crg_damages cd on cl.gkey = cd.crglot_gkey
		inner join 	SPARCSN4PRD.crg_damage_types cdt on cd.dmgs_gkey = cdt.gkey
where   rownum <500
        --and cl.id IN ('44272318-1-1','60820675-1-2')
--group by cl.goods_gkey, cl.id
order by cl.created 
;
---------------------------------------------------------------------------------------------
-- Comparar Count Distinto e Count Real  - Verificação de logica 
  -- Se Count Distindo = Count Real entao retorna avaria_cargo_lot
  --
select  
        cl.goods_gkey gdgkey 
        ,COUNT(Distinct(cdt.description)) AS qtddist--, cdt.gkey cdtgkey,
        ,COUNT(cdt.description) qtdreal
        ,listagg(cdt.description,'; ') within group (order by cdt.description) avaria_cargo_lot
from
                    SPARCSN4PRD.crg_lots cl --on  ig.gkey = cl.goods_gkey
		inner join	SPARCSN4PRD.crg_damages cd on cl.gkey = cd.crglot_gkey
		inner join 	SPARCSN4PRD.crg_damage_types cdt on cd.dmgs_gkey = cdt.gkey
where 
        rownum < 500
        --and cl.id IN ('60820675-1-2', '44272318-1-1')
group by
        cl.goods_gkey
;
--------------------------------------------------------------------------------------------
-- Solução para avarias duplicadas query 2
select  
      goods_gkey 
      ,listagg(description,'; ') within group (order by description) avaria_cargo_lot
from ( select distinct cdt.description, cl.goods_gkey
         from
             SPARCSN4PRD.crg_lots cl --on  ig.gkey = cl.goods_gkey
             inner join	SPARCSN4PRD.crg_damages cd on cl.gkey = cd.crglot_gkey
             inner join SPARCSN4PRD.crg_damage_types cdt on cd.dmgs_gkey = cdt.gkey
     ) 
where    rownum < 500                                              --id IN ('60820675-1-2')
--and goods_gkey = 54587423 
group by goods_gkey -- 34308619 -- 54587423
;
--------------------------------------------------------------------------------------------
select * from (
select  
        cl.id id
        ,COUNT(Distinct(cdt.description)) qtddist--, cdt.gkey cdtgkey,
        ,COUNT(cdt.description) qtdreal
        --,listagg(cdt.description,'; ') within group (order by cdt.description) avaria_cargo_lot
from
                    SPARCSN4PRD.crg_lots cl --on  ig.gkey = cl.goods_gkey
		inner join	SPARCSN4PRD.crg_damages cd on cl.gkey = cd.crglot_gkey
		inner join 	SPARCSN4PRD.crg_damage_types cdt on cd.dmgs_gkey = cdt.gkey
        inner join  SPARCSN4PRD.inv_unit unt on unt.id = cl.id
        inner join  SPARCSN4PRD.inv_unit_fcy_visit iufv on unt.active_ufv=iufv.gkey
where 
        --rownum < 5000
        cd.CREATED > TO_DATE('01/01/2019 00:00:00' , 'DD/MM/YYYY HH24:MI:SS')
        and  iufv.visit_state='1ACTIVE'
        --and cl.id IN ('60820675-1-2')
group by
        cl.id
)where qtdreal > 1
;


-- Solução -------------------------------------------------------

Select gdgkey,
        case 
            when qtddist = qtdreal then avaria_cargo_lot 
            when qtddist < qtdreal then  (
                                        )
           else qtddist||' e '||qtdreal
        end avaria_cargo_lot
from(


        
)
;

--------------------------------------------------------------------
    
with avariadistinta as (    
     select  
         goods_gkey 
        ,listagg(description,'; ') within group (order by description) avaria_cargo_lot
     from ( select distinct cdt.description, cl.goods_gkey
            from
                    SPARCSN4PRD.crg_lots cl --on  ig.gkey = cl.goods_gkey
             inner join	SPARCSN4PRD.crg_damages cd on cl.gkey = cd.crglot_gkey
             inner join SPARCSN4PRD.crg_damage_types cdt on cd.dmgs_gkey = cdt.gkey
            )                                             
group by goods_gkey
) 
select * from avariadistinta;
       