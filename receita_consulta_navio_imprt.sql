-- Consulta navio exportação 
-- IMPORTACAO
/*with averbacao as (
                select  cr.CUSTOMREGIST_BILLOFLADIN blkey, ctd.CUSTOMTPDOC_SHORTNAME tipo_doc,
                         ctd.CUSTOMTPDOC_NAME descric, cd.CUSTOMD_NBR_S averb, csr.CUSTOMSTAREG_DESCRIPTION stt
                from SPARCSN4.custom_registry cr
                    ,SPARCSN4.custom_document cd
                    ,SPARCSN4.custom_typedocument ctd
                    ,SPARCSN4.custom_statusregistry csr
                where
                        cd.gkey = cr.CUSTOMREGIST_DOCUMENT
                    and ctd.gkey = cd.CUSTOMD_TYPEDOC
                    and csr.gkey = cr.customregist_status
                    and cr.CUSTOMREGIST_BILLOFLADIN is not null
                    --and bl.nbr IN ('1590','21854272')
)*/
SELECT 
     null as navio
    ,null as prev_atra
    ,null as ata
    ,null as prev_desatrac
    ,null as desatrac
    ,null as ce_mercante
    
    ,null as container
    ,null as tp_cont
    ,null as iso
    ,null as c_v  -- Corrigir
    
    ,null as peso_bt_manif
    ,null as peso_bt_afer
    ,null as peso_vgm
    ,null as dt_entrada
    ,null as dt_saida
    
    ,null as pais_orig -- Corrigir
    ,null as due
    ,null as cod_recint_despac
    ,null as doc_num
    ,null as consig
    ,null as descr_mercad -- Corrigir

    ,null as servc_port
    ,null as num_viagem
    ,null as che_vaz
    ,null as posic_atual
    
    ,(
                select  ctd.CUSTOMTPDOC_SHORTNAME tipo_doc
                from SPARCSN4.custom_registry cr
                    ,SPARCSN4.custom_document cd
                    ,SPARCSN4.custom_typedocument ctd
                    ,SPARCSN4.custom_statusregistry csr
                where
                        cd.gkey = cr.CUSTOMREGIST_DOCUMENT
                    and ctd.gkey = cd.CUSTOMD_TYPEDOC
                    and csr.gkey = cr.customregist_status
                    and cr.CUSTOMREGIST_BILLOFLADIN is not null 
                    and cr.CUSTOMREGIST_BILLOFLADIN = bol.gkey
    ) as tp_doc
FROM
   SPARCSN4.vsl_vessel_visit_details
WHERE 
    2=1
UNION
SELECT 
     vsl.name                                       as navio
    ,to_char(avd.eta, 'DD/MM/YYYY HH24:MI')         as prev_atra
    ,to_char(acv.ata, 'DD/MM/YYYY HH24:MI')         as ata
    ,to_char(avd.etd, 'DD/MM/YYYY HH24:MI')         as prev_desatrac
    ,to_char(acv.atd, 'DD/MM/YYYY HH24:MI')         as desatrac
    ,unt.flex_string13                              as ce_mercante    
    ,unt.id                                         as container
    ,substr(ret.nominal_length, 4, 2)               as tp_cont
    ,ret.id                                         as iso
    ,ufv.arrive_pos_locid                           as c_v
    ,unt.goods_ctr_wt_kg_advised                    as peso_bt_manif
    -- Se Usar Scale Gate (KG). Se estiver nulo, usar Scale Yard. Se não aplicar o else
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
     end                                               peso_bt_afer
     
    ,unt.goods_and_ctr_wt_kg                        as peso_vgm
    ,to_char(ufv.time_in, 'DD/MM/YYYY HH24:MI:SS')  as dt_entrada
    ,to_char(ufv.time_out, 'DD/MM/YYYY HH24:MI:SS') as dt_saida
    ,ruc.cntry_code                                 as pais_orig
    ,ufv.flex_string10                              as due
    ,null as cod_recint_despac
    -- Buscar documento do Shipper
    ,rbs.sms_number||': '||rbs.website_url          as doc_num
    ,rbs.name                                       as consig
    ,null                                           as descr_mercad

    ,rcs.name                                       as servc_port
    ,acv.id                                         as num_viagem

    ,case unt.freight_kind
        when 'MTY' 
            then 'VAZIO'
        when 'FCL' 
            then 'CHEIO'
        when 'LCL' 
            then 'CHEIO'
        else unt.freight_kind
     end                                               che_vaz
    ,ufv.last_pos_name                              as posic_atual
    ,null as tp_doc 
FROM
    -- Juncao com a Tab de Visit
    SPARCSN4.vsl_vessel_visit_details       vvd
    inner join SPARCSN4.vsl_vessels         vsl     on vsl.gkey = vvd.vessel_gkey
    inner join SPARCSN4.argo_carrier_visit  acv     on acv.cvcvd_gkey = vvd.Vvd_Gkey
    inner join SPARCSN4.argo_visit_details  avd     on avd.gkey = acv.cvcvd_gkey
    inner join SPARCSN4.ref_carrier_service rcs     on rcs.gkey = avd.service
    -- Juncao com a Tab de Unit
    inner join SPARCSN4.inv_unit_fcy_visit  ufv     on acv.id = ufv.arrive_pos_locid -- Somente importacao
    inner join SPARCSN4.inv_unit            unt     on unt.gkey = ufv.unit_gkey
    inner join SPARCSN4.ref_equipment       ref     on ref.id_full = unt.id
    inner join SPARCSN4.ref_equip_type      ret     on ret.gkey = ref.eqtyp_gkey
    -- Jucao com a Tab de Consignatario
    inner join SPARCSN4.inv_goods           god     on god.gkey = unt.goods
    inner join SPARCSN4.ref_bizunit_scoped  rbs     on rbs.gkey = god.consignee_bzu
    inner join SPARCSN4.crg_bills_of_lading bol     on  bol.nbr = god.BL_NBR
    -- Juncao com a Tab de Routing
    inner join SPARCSN4.ref_routing_point   rrp     on rrp.gkey = unt.pol_gkey
    inner join SPARCSN4.ref_unloc_code      ruc     on ruc.gkey = rrp.unloc_gkey
    inner join SPARCSN4.argo_facility       afc     on afc.gkey = ufv.fcy_gkey

WHERE
    unt.category = 'IMPRT'
    and ufv.time_in is not null
    and afc.id in ('LTR')
    -- Usar Data de Entrada ou Previsão de Atracacao ou Previsao de Desembarque
    and (
            trunc(ufv.time_in) >= TO_DATE ('01.06.2018','DD/MM/YYYY')
                and trunc(ufv.time_in) <= TO_DATE ('30.06.2018','DD/MM/YYYY')
        /*or 
            trunc(avd.eta) >= TO_DATE ('30.06.2050','DD/MM/YYYY')
                and trunc(avd.eta) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
        or
            trunc(avd.etd) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
                and trunc(avd.etd) <= TO_DATE ('30.06.2050','DD/MM/YYYY')*/
        )
        and rownum <51
;
  /*  

    
