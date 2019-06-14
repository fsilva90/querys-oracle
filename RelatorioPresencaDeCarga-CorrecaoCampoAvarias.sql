select  
        cl.goods_gkey
		,listagg(cdt.description,'; ') within group (order by cdt.description) as avaria_cargo_lot
from
                    SPARCSN4PRD.crg_lots cl --on  ig.gkey = cl.goods_gkey
		inner join	SPARCSN4PRD.crg_damages cd on cl.gkey = cd.crglot_gkey
		inner join 	SPARCSN4PRD.crg_damage_types cdt on cd.dmgs_gkey = cdt.gkey
where   rownum <500
        and cl.id IN ('44272318-1-1','60820675-1-2')
group by
        cl.goods_gkey 
;
---------------------------------------------------------------------------------------------
-- Comparar Count Distinto e Count Real  - Verificação de logica 
  -- Se Count Distindo = Count Real entao retorna avaria_cargo_lot
  --
select  
        cl.goods_gkey gdgkey 
        ,COUNT(Distinct(cdt.description)) AS qtd--, cdt.gkey cdtgkey,
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
-- Solução 

Select gdgkey,
        case 
            when qtd > 1 then avaria_cargo_lot 
            when qtd = 1 then  (select cdt.description 
                                         from   
                                                SPARCSN4PRD.crg_lots cl
                                                ,SPARCSN4PRD.crg_damages cd
                                                ,SPARCSN4PRD.crg_damage_types cdt 
                                         where 
                                                cl.goods_gkey = gdgkey
                                                and cd.crglot_gkey = cl.gkey
                                                and cdt.gkey = cd.dmgs_gkey 
                                                and rownum = 1)
        end avaria_cargo_lot
from(

select  
        cl.goods_gkey gdgkey 
        ,COUNT(Distinct(cdt.description)) AS qtd--, cdt.gkey cdtgkey,
        ,COUNT(cdt.description)
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
        
)
;

