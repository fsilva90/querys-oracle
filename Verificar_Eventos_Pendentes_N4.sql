SELECT  unit.id UNIT, unit.category, to_char(unit.create_time ,'DD/MM/YYYY') UNIT_CREATE, et.id EVENTO, to_char(event.created ,'DD/MM/YYYY') EV_CREATE, event.billing_extract_batch_id,acv.id VIAGEM
        --'alterEvent('||EVENT.gkey||'L);',et.id EVENTO,acv.id
        --COUNT(*)
FROM    SPARCSN4PRD.SRV_EVENT EVENT
        ,SPARCSN4PRD.srv_event_types ET
        ,SPARCSN4PRD.inv_unit unit
        ,SPARCSN4PRD.inv_unit_fcy_visit ufv
        ,SPARCSN4PRD.argo_carrier_visit acv
WHERE  
        EVENT.EVENT_TYPE_GKEY = ET.GKEY
        and unit.gkey = ufv.unit_gkey
        --and ufv.time_out is null
        --and ufv.time_in is not null
        --and ufv.visit_state = '1ACTIVE'
        and ufv.arrive_pos_locid = acv.id
        and EVENT.FACILITY_GKEY IN (47262)
        and event.APPLIED_TO_NATURAL_KEY = unit.id
        --and ET.IS_BILLABLE = 1
        and event.billing_extract_batch_id is not null
        --AND event.billing_extract_batch_id != -999999999
        --AND event.billing_extract_batch_id = -999999999
        and Trunc(event.created) >= TO_DATE( '01.05.2019' , 'DD/MM/YYYY')
        and Trunc(event.created) <= TO_DATE( '30.06.2019' , 'DD/MM/YYYY')
        --and acv.id IN ('MMCL922','LPAN258','ALEX922','SAEX921','MMEM920')
        and event.APPLIED_TO_NATURAL_KEY = 'MSKU4186286'
ORDER BY unit.create_time 
;


