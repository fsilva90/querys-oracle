-- Consulta navio exportação 
-- IMPORTACAO

/*with averbacao as (
                    select  cr.CUSTOMREGIST_BILLOFLADIN blkey, ctd.CUSTOMTPDOC_SHORTNAME tipo_doc,
                            ctd.CUSTOMTPDOC_NAME descric, cd.CUSTOMD_NBR_S averb, csr.CUSTOMSTAREG_DESCRIPTION stt
                    from    SPARCSN4.custom_registry cr ,SPARCSN4.custom_document cd ,SPARCSN4.custom_typedocument ctd ,SPARCSN4.custom_statusregistry csr
                    where   cd.gkey = cr.CUSTOMREGIST_DOCUMENT and ctd.gkey = cd.CUSTOMD_TYPEDOC  and csr.gkey = cr.customregist_status 
                            and cr.CUSTOMREGIST_BILLOFLADIN is not null
                    --and bl.nbr IN ('1590','21854272')
)*/
SELECT 
(select  ctd.CUSTOMTPDOC_SHORTNAME||' - '||ctd.CUSTOMTPDOC_NAME descric
 from    SPARCSN4.custom_registry cr ,SPARCSN4.custom_document cd ,SPARCSN4.custom_typedocument ctd ,SPARCSN4.custom_statusregistry csr
 where   cd.gkey = cr.CUSTOMREGIST_DOCUMENT and ctd.gkey = cd.CUSTOMD_TYPEDOC  and csr.gkey = cr.customregist_status 
 and cr.CUSTOMREGIST_BILLOFLADIN is not null and cr.CUSTOMREGIST_BILLOFLADIN = bol.gkey
) teste
    
FROM
    -- Juncao com a Tab de Visit
    SPARCSN4.vsl_vessel_visit_details       vvd
    inner join SPARCSN4.vsl_vessels         vsl     on vsl.gkey = vvd.vessel_gkey
    inner join SPARCSN4.argo_carrier_visit  acv     on acv.cvcvd_gkey = vvd.vvd_Gkey
    inner join SPARCSN4.argo_visit_details  avd     on avd.gkey = acv.cvcvd_gkey
    inner join SPARCSN4.ref_carrier_service rcs     on rcs.gkey = avd.service
    -- Juncao com a Tab de Unit

    ,SPARCSN4.argo_facility                 afc    
    ,SPARCSN4.ref_bizunit_scoped            rbs
    ,SPARCSN4.inv_unit_fcy_visit            ufv
    ,SPARCSN4.inv_unit                      unt
    ,SPARCSN4.ref_routing_point             rrp
    ,SPARCSN4.ref_unloc_code                ruc
    ,SPARCSN4.inv_goods                     god
    ,SPARCSN4.crg_bills_of_lading           bol
    --,tpcnt
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
        and rownum <51
;




