-- Consulta navio exportação 
-- EXPORTACAO 08/07/2019
SELECT 
     null as navio
    ,null as prev_atra
    ,null as ata
    ,null as prev_desatrac
    ,null as desatrac
    ,null as container
    ,null as tp_cont
    ,null as iso
    ,null as c_v
    ,null as peso_bt_manif
    ,null as peso_bt_afer
    ,null as peso_vgm
    ,null as dt_entrada
    ,null as dt_saida
    ,null as pais_dest
    ,null as due
    ,null as cod_recint_despac
    ,null as doc_num
    ,null as exportador
    ,null as descr_mercad
    ,null as ce_mercante
    ,null as servc_port
    ,null as num_viagem
    ,null as tara
    ,null as che_vaz
    ,null as num_lacre1
    ,null as num_lacre2
    ,null as num_lacre3
    ,null as num_lacre4
    ,null as posic_atua
FROM
   SPARCSN4.vsl_vessel_visit_details
WHERE 
    2=1
UNION
SELECT 
     vsl.name                                           navio
    ,to_char(avd.eta, 'DD/MM/YYYY HH24:MI')             prev_atra
    ,to_char(acv.ata, 'DD/MM/YYYY HH24:MI')             ata
    ,to_char(avd.etd, 'DD/MM/YYYY HH24:MI')             prev_desatrac
    ,to_char(acv.atd, 'DD/MM/YYYY HH24:MI')             desatrac
    ,unt.id                                             container
    ,substr(ret.nominal_length, 4, 2)                   tp_cont
    ,ret.id                                             iso
    ,ufv.last_pos_locid                                 c_v
    ,unt.goods_ctr_wt_kg_advised                        peso_bt_manif
------------------- Descricao de Peso Buto Aferido -------------------
    ,case
        when unt.goods_ctr_wt_kg_gate_measured is not null -- Se existir Scale Gate e nao exisitir Scale Yard, retornar Scale Gate
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is null
                then to_char(unt.goods_ctr_wt_kg_gate_measured)
        when unt.goods_ctr_wt_kg_gate_measured is null     -- Se nao exisitir Scale Gate, retornar Scale Yard
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is not null
                then to_char(unt.Goods_Ctr_Wt_Kg_Yard_Measured)
        when unt.goods_ctr_wt_kg_gate_measured is not null -- Se existir Scale Gate e exisitir Scale Yard, retornar Scale Yard
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is not null
                then to_char(unt.Goods_Ctr_Wt_Kg_Yard_Measured)
        else '-'                                           -- Se nao existir Scale Gate e nao exisitir Scale Yard, nao retornar valor
     end                                                peso_bt_afer
----------------------------------------------------------------------
    ,unt.goods_and_ctr_wt_kg                            peso_vgm
    ,to_char(ufv.time_in, 'DD/MM/YYYY HH24:MI:SS')      dt_entrada
    ,to_char(ufv.time_out, 'DD/MM/YYYY HH24:MI:SS')     dt_saida
    ,ruc.cntry_code                                     pais_dest
-------------------------- DUE  ----------------------------------
    ,case 
        when ufv.flex_string01 like '%DUE%' -- Se existir DUE
               then ufv.flex_string01
        when ufv.flex_string01 like '%PCI%' -- Se existir PCI
               then ufv.flex_string01               
     end                                                due
    ,null                                               cod_recint_despac
---------------------- Documento Exportador -----------------------
    ,case 
        when ebo.shipper_gkey is not null 
            then (-- Se existir Shipper
                       select rbs.sms_number||': '||rbs.WEBSITE_URL
                        from SPARCSN4.ref_bizunit_scoped rbs
                        where life_cycle_state = 'ACT' and role in ('SHIPPER') and rbs.gkey = ebo.shipper_gkey 
                 )
        else    ( -- Se não tiver Shipper, buscar Liner Operator 
                       select rbs.sms_number||': '||rbs.website_url
                        from  SPARCSN4.ref_bizunit_scoped rbs
                        where life_cycle_state = 'ACT' and role in ('LINEOP') and rbs.gkey = ebo.line_gkey 
                )
     end                                            doc_num
---------------------- Nome Exportador -----------------------
    ,case 
        when ebo.shipper_gkey is not null
            then (-- Se existir Shipper
                       select rbs.name 
                        from SPARCSN4.ref_bizunit_scoped rbs
                        where life_cycle_state = 'ACT' and role in ('SHIPPER') and rbs.gkey = ebo.shipper_gkey 
                 )
        else ( -- Se não existir Shipper, buscar Liner Operator 
                       select rbs.name
                        from  SPARCSN4.ref_bizunit_scoped rbs
                        where life_cycle_state = 'ACT' and role in ('LINEOP') and rbs.gkey = ebo.line_gkey 
                    )
     end                                            exportador
------------------- Descricao Mercadoria ------------------------
    ,case 
        when unt.freight_kind in ('FCL','LCL') -- Se unit for cheio, retornar mercadoria
             then ( 
                    select rco.short_name
                    from SPARCSN4.inv_goods god, sparcsn4.ref_commodity rco     
                    where rco.gkey = god.commodity_gkey and god.gkey = unt.goods
                  )        
        else null 
    end merc
-----------------------------------------------------------------
    ,unt.flex_string13                                  ce_mercante
    ,rcs.name                                           servc_port
    ,acv.id                                             num_viagem
    ,ref.tare_kg                                        tara
-------------------- Descricao de Cheio e Vazio -------------------
    ,case unt.freight_kind
        when 'MTY' then 'VAZIO'
        when 'FCL' then 'CHEIO'
        when 'LCL' then 'CHEIO'
        else unt.freight_kind
     end                                                che_vaz
-------------------------Desc de Lacre -----------------------------
    ,seal_nbr1                                          num_lacre1
    ,seal_nbr2                                          num_lacre2
    ,seal_nbr3                                          num_lacre3
    ,seal_nbr4                                          num_lacre4
--------------------------------------------------------------------
    ,ufv.last_pos_name                                  posic_atual
FROM
    -- Juncao com a Tab de Visit
    SPARCSN4.vsl_vessel_visit_details       vvd
    inner join SPARCSN4.vsl_vessels         vsl     on vsl.gkey = vvd.vessel_gkey
    inner join SPARCSN4.argo_carrier_visit  acv     on acv.cvcvd_gkey = vvd.Vvd_Gkey
    inner join SPARCSN4.argo_visit_details  avd     on avd.gkey = acv.cvcvd_gkey
    inner join SPARCSN4.ref_carrier_service rcs     on rcs.gkey = avd.service
    -- Juncao com a Tab de Unit
    inner join SPARCSN4.inv_unit_fcy_visit  ufv     on acv.id = ufv.last_pos_locid -- Somente exportação
    inner join SPARCSN4.inv_unit            unt     on unt.gkey = ufv.unit_gkey
    inner join SPARCSN4.ref_equipment       ref     on ref.id_full = unt.id
    inner join SPARCSN4.ref_equip_type      ret     on ret.gkey = ref.eqtyp_gkey
    -- Juncao com a Tab de Routing
    inner join SPARCSN4.ref_routing_point   rrp     on rrp.gkey = unt.pod1_gkey
    inner join SPARCSN4.ref_unloc_code      ruc     on ruc.gkey = rrp.unloc_gkey
    inner join SPARCSN4.argo_facility       afc     on afc.gkey = ufv.fcy_gkey
    -- Juncao com a Tab do Booking
    inner join SPARCSN4.inv_unit_equip      iue     on iue.unit_gkey = unt.gkey 
    inner join SPARCSN4.inv_eq_base_order_item eoi  on eoi.gkey = iue.depart_order_item_gkey 
    inner join SPARCSN4.inv_eq_base_order   ebo     on ebo.gkey = eoi.eqo_gkey
WHERE
    unt.category = 'EXPRT' 
    and unt.freight_kind not in ('BBK')
    and afc.id in ('LTR')
    and (   -- Previsto
            trunc(avd.eta) >= TO_DATE ('20.06.2050','DD/MM/YYYY')
                and trunc(avd.eta) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
        or  -- Atracado
            trunc(acv.ata) >= TO_DATE ('20.06.2050','DD/MM/YYYY')
                and trunc(acv.ata) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
        or  -- Operado
            trunc(acv.atd) >= TO_DATE ('20.06.2050','DD/MM/YYYY')
                and trunc(acv.atd) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
        or  -- Data Inicial / Data Final           
            trunc(ufv.time_in) >= TO_DATE ('01.05.2019','DD/MM/YYYY')
                and trunc(ufv.time_out) <= TO_DATE ('15.05.2019','DD/MM/YYYY')
        )
    ;