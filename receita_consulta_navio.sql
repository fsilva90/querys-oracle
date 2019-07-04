-- Consulta navio exportação 
-- EXPORTACAO
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
     vsl.name                                  as navio
    ,to_char(avd.eta, 'DD/MM/YYYY HH24:MI')     as prev_atra
    ,to_char(acv.ata, 'DD/MM/YYYY HH24:MI')     as ata
    ,to_char(avd.etd, 'DD/MM/YYYY HH24:MI')     as prev_desatrac
    ,to_char(acv.atd, 'DD/MM/YYYY HH24:MI')     as desatrac
    ,unt.id                                     as container
    ,substr(ret.nominal_length, 4, 2)           as tp_cont
    ,ret.id                                     as iso
    ,ufv.last_pos_locid                         as c_v
    ,unt.goods_ctr_wt_kg_advised                as peso_bt_manif
    ,case
        when unt.goods_ctr_wt_kg_gate_measured is not null 
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is null
                then to_char(unt.goods_ctr_wt_kg_gate_measured)
        when unt.goods_ctr_wt_kg_gate_measured is null 
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is not null
                then to_char(unt.Goods_Ctr_Wt_Kg_Yard_Measured)
        when unt.goods_ctr_wt_kg_gate_measured is not null 
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is not null
                then to_char(unt.Goods_Ctr_Wt_Kg_Yard_Measured)
        else '-'
     end                                           peso_bt_afer
    ,unt.goods_and_ctr_wt_kg as peso_vgm
    ,to_char(ufv.time_in, 'DD/MM/YYYY HH24:MI:SS')  as dt_entrada
    ,to_char(ufv.time_out, 'DD/MM/YYYY HH24:MI:SS') as dt_saida
    ,ruc.cntry_code                                 as pais_dest
    ,ufv.flex_string10                              as due
    ,null as cod_recint_despac
    -- Buscar documento do Shipper
    ,case 
        when ebo.shipper_gkey is not null
            then (
                       select 
                            --rbs.ID, rbs.NAME, 
                            rbs.sms_number||': '||rbs.WEBSITE_URL
                        from 
                            SPARCSN4.ref_bizunit_scoped rbs
                        where 
                            life_cycle_state = 'ACT'
                             and role in ('SHIPPER') 
                             and rbs.gkey = ebo.shipper_gkey 
                    )
            
        else ( -- Se não tiver Shipper, buscar Liner Operator 
                       select 
                            --rbs.ID, rbs.NAME,
                            case 
                                when rbs.sms_number = 'CNPJ'        then rbs.sms_number||': '||rbs.website_url
                                when rbs.sms_number = 'ESTRANGEIRO' then rbs.sms_number||': '||rbs.website_url
                                else rbs.id
                            end cnpj
                        from 
                            SPARCSN4.ref_bizunit_scoped rbs
                        where 
                            life_cycle_state = 'ACT'
                             and role in ('LINEOP') 
                             and rbs.gkey = ebo.line_gkey 
                    )
     end                                            doc_num
    ,case 
        when ebo.shipper_gkey is not null
            then (
                       select 
                            --rbs.ID,
                            rbs.name 
                        from 
                            SPARCSN4.ref_bizunit_scoped rbs
                        where 
                            life_cycle_state = 'ACT'
                             and role in ('SHIPPER') 
                             and rbs.gkey = ebo.shipper_gkey 
                    )
            
        else ( -- Se não tiver Shipper, buscar Liner Operator 
                       select 
                            --rbs.ID, 
                            rbs.name
                        from 
                            SPARCSN4.ref_bizunit_scoped rbs
                        where 
                            life_cycle_state = 'ACT'
                             and role in ('LINEOP') 
                             and rbs.gkey = ebo.line_gkey 
                    )
     end                                            exportador
    ,rco.short_name                              as descr_mercad
    ,unt.flex_string13                           as ce_mercante
    ,rcs.name                                    as servc_port
    ,acv.id                                      as num_viagem
    ,case
        when length(ref.tare_kg) < 4
            then '0.'||ref.tare_kg
        when length(ref.tare_kg) = 4
            then substr(ref.tare_kg, 0,1)
                 ||'.'||substr(ref.tare_kg, 2,3)
        when length(ref.tare_kg) > 4
            then substr(ref.tare_kg, 0,2)
                 ||'.'||substr(ref.tare_kg, 3,3)
     end                                            tara
    ,case unt.freight_kind
        when 'MTY' 
            then 'VAZIO'
        when 'FCL' 
            then 'CHEIO'
        when 'LCL' 
            then 'CHEIO'
        else unt.freight_kind
     end                                            che_vaz
    ,seal_nbr1                                   as num_lacre1
    ,seal_nbr2                                   as num_lacre2
    ,seal_nbr3                                   as num_lacre3
    ,seal_nbr4                                   as num_lacre4
    ,ufv.last_pos_name                           as posic_atual
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
    inner join SPARCSN4.inv_goods           god     on god.gkey = unt.goods
    inner join sparcsn4.ref_commodity       rco     on rco.gkey = god.commodity_gkey
    -- Juncao com a Tab de Routing
    inner join SPARCSN4.ref_routing_point   rrp     on rrp.gkey = unt.pod1_gkey
    inner join SPARCSN4.ref_unloc_code      ruc     on ruc.gkey = rrp.unloc_gkey
    inner join SPARCSN4.argo_facility       afc     on afc.gkey = ufv.fcy_gkey
    -- Juncao com a Tab do Booking
    inner join SPARCSN4.inv_unit_equip      iue     on iue.unit_gkey = unt.gkey 
    inner join SPARCSN4.inv_eq_base_order_item eoi on eoi.gkey = iue.depart_order_item_gkey 
    inner join SPARCSN4.inv_eq_base_order   ebo     on ebo.gkey = eoi.eqo_gkey
    
WHERE
    unt.category = 'EXPRT'
    and unt.freight_kind != 'BBK'
    and afc.id in ('LTR')
    and (
         trunc(ufv.time_in) >= TO_DATE ('30.06.2050','DD/MM/YYYY')
             and trunc(ufv.time_in) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
        or 
         trunc(avd.eta) >= TO_DATE ('30.06.2018','DD/MM/YYYY')
             and trunc(avd.etd) <= TO_DATE ('30.06.2018','DD/MM/YYYY')
        )
    ;
  /*  
            (((NOT UFV.ACTUAL_OB_CV = ACV.GKEY) AND UFV.ACTUAL_IB_CV = ACV.GKEY)
            OR
            (UFV.ACTUAL_OB_CV = ACV.GKEY AND (NOT UFV.ACTUAL_IB_CV = ACV.GKEY)))
    
