-- Consulta navio exportação 
-- EXPORTACAO 08/07/2019
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

    ,null as pais_orig
    ,null as due
    ,null as cod_recint_despac
    ,null as doc_num
    ,null as consig
    ,null as descr_mercad -- Corrigir

    ,null as servc_port
    ,null as num_viagem
    ,null as che_vaz
    ,null as posic_atual
    ,null as tipo_doc
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
    ,unt.flex_string13                                  ce_mercante    
    ,unt.id                                             container
 ------------------- Descricao de Tipo Container --------------------  
    ,(select substr(ret.nominal_length, 4, 2) tp_cont
      from SPARCSN4.ref_equipment ref ,SPARCSN4.ref_equip_type ret
      where ret.gkey = ref.eqtyp_gkey and ref.id_full = unt.id
     )                                                  tp_cont
 ------------------- Descricao de Tipo ISO --------------------------
    ,(select ret.id iso
      from SPARCSN4.ref_equipment ref 
      ,SPARCSN4.ref_equip_type ret
      where ret.gkey = ref.eqtyp_gkey and ref.id_full = unt.id
     )                                                  iso
---------------------------------------------------------------------     
    ,ufv.arrive_pos_locid                               c_v
    ,unt.goods_ctr_wt_kg_advised                        peso_bt_manif
------------------- Descricao de Peso Buto Aferido -------------------
    ,case
        when unt.goods_ctr_wt_kg_gate_measured is not null -- Retornar Scale Gate
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is null
                then to_char(unt.goods_ctr_wt_kg_gate_measured)
        when unt.goods_ctr_wt_kg_gate_measured is null     -- Se nao exisitir Scale Gate, retornar Scale Yard
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is not null
                then to_char(unt.Goods_Ctr_Wt_Kg_Yard_Measured)
        when unt.goods_ctr_wt_kg_gate_measured is not null -- Retornar Scale Yard
            and unt.Goods_Ctr_Wt_Kg_Yard_Measured is not null
                then to_char(unt.Goods_Ctr_Wt_Kg_Yard_Measured)
        else '-'                                          
     end                                                peso_bt_afer
-------------------------------------------------------------------  
    ,unt.goods_and_ctr_wt_kg                            peso_vgm
    ,to_char(ufv.time_in, 'DD/MM/YYYY HH24:MI:SS')      dt_entrada
    ,to_char(ufv.time_out, 'DD/MM/YYYY HH24:MI:SS')     dt_saida
    ,ruc.cntry_code                                     pais_orig
    ,ufv.flex_string10                                  due
    ,null as cod_recint_despac
------------------ Descricao Nome e Doc Importador ----------------
    ,rbs.sms_number||': '||rbs.website_url as doc_num
    ,rbs.name as consig
-------------------------------------------------------------------
    ,
    ( 
      select rco.short_name
      from SPARCSN4.inv_goods god, sparcsn4.ref_commodity rco     
      where rco.gkey = god.commodity_gkey and god.gkey = unt.goods 
     )

     descr_mercad
-------------------------------------------------------------------
    ,rcs.name                                           servc_port
    ,acv.id                                             num_viagem

-------------------- Descricao de Cheio e Vazio -------------------
    ,case unt.freight_kind
        when 'MTY' then 'VAZIO'
        when 'FCL' then 'CHEIO'
        when 'LCL' then 'CHEIO'
        when 'BBK' then 'CARGA SOLTA'
        else unt.freight_kind
     end                                                che_vaz
----------------------Tipo Documento -------------------------------     
    ,ufv.last_pos_name                                  posic_atual
    ,null as                                            tp_doc 
FROM
    -- Juncao com a Tab de Visit
    SPARCSN4.vsl_vessel_visit_details       vvd
    inner join SPARCSN4.vsl_vessels         vsl     on vsl.gkey = vvd.vessel_gkey
    inner join SPARCSN4.argo_carrier_visit  acv     on acv.cvcvd_gkey = vvd.vvd_Gkey
    inner join SPARCSN4.argo_visit_details  avd     on avd.gkey = acv.cvcvd_gkey
    inner join SPARCSN4.ref_carrier_service rcs     on rcs.gkey = avd.service

    ,SPARCSN4.argo_facility                 afc    
    ,SPARCSN4.ref_bizunit_scoped            rbs
    ,SPARCSN4.inv_unit_fcy_visit            ufv
    ,SPARCSN4.inv_unit                      unt
    ,SPARCSN4.ref_routing_point             rrp
    ,SPARCSN4.ref_unloc_code                ruc
    ,SPARCSN4.inv_goods                     god
    ,SPARCSN4.crg_bills_of_lading           bol
WHERE
    unt.category = 'IMPRT'
    --and unt.id in ('18297891-1-1','17324267-1-1','TRIU0570794')
    and ufv.time_in is not null
    and afc.id in ('LTR')
    and unt.gkey = ufv.unit_gkey
    and god.gkey = unt.goods
    and afc.gkey = ufv.fcy_gkey
    and rrp.gkey = unt.pol_gkey
    and ruc.gkey = rrp.unloc_gkey
    and bol.nbr = god.bl_nbr
    and ( 
            ((not unt.freight_kind != 'BBK') and  ufv.arrive_pos_locid = acv.id) 
        or
            (unt.declrd_ib_cv = acv.gkey and ( not unt.freight_kind = 'bbk'))
        )
    and (
            ((not god.consignee_bzu is null) and god.consignee_bzu = rbs.gkey)
         or
            (god.shipper_bzu = rbs.gkey and (not god.consignee_bzu is not null))
        )
        -- Usar Data de Entrada ou Previsão de Atracacao ou Previsao de Desembarque
    /*and (
            trunc(ufv.time_in) >= TO_DATE ('01.06.2018','DD/MM/YYYY')
                and trunc(ufv.time_in) <= TO_DATE ('30.06.2018','DD/MM/YYYY')
        /*or 
            trunc(avd.eta) >= TO_DATE ('30.06.2050','DD/MM/YYYY')
                and trunc(avd.eta) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
        or
            trunc(avd.etd) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
                and trunc(avd.etd) <= TO_DATE ('30.06.2050','DD/MM/YYYY')
        )*/
;
select distinct gds.gkey --, bl.nbr
                ,ctd.CUSTOMTPDOC_SHORTNAME||' - '||ctd.CUSTOMTPDOC_NAME descric
from    SPARCSN4.custom_registry cr ,SPARCSN4.custom_document cd 
        ,SPARCSN4.custom_typedocument ctd 
        ,SPARCSN4.inv_goods gds
        ,SPARCSN4.crg_bills_of_lading bl
        ,SPARCSN4.custom_statusregistry csr
where   cd.gkey = cr.CUSTOMREGIST_DOCUMENT 
        and ctd.gkey = cd.CUSTOMD_TYPEDOC 
        and cr.CUSTOMREGIST_BILLOFLADIN = bl.gkey 
        and gds.bl_nbr = bl.nbr
        and csr.gkey = cr.customregist_status
        and csr.customstareg_description != 'Cancelado'   
; 
