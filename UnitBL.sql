SELECT 
        BL.NBR                                  BL
        ,UNIT.ID                                UNIT
        ,CMDY.ID                                NCM
        ,CMDY.SHORT_NAME                        DESCRICAO
        --,BLNCM.*
        
FROM    
        SPARCSN4PRD.CUSTOM_BLNCM                BLNCM
        ,SPARCSN4PRD.CRG_BILLS_OF_LADING        BL
        ,SPARCSN4PRD.REF_COMMODITY 				CMDY
        ,SPARCSN4PRD.INV_GOODS                  GOODS
        ,SPARCSN4PRD.INV_UNIT                   UNIT
WHERE   
        BL.GKEY = BLNCM.CUSTOMBLNCM_BILLOFLADING
        AND CMDY.GKEY = BLNCM.CUSTOMBLNCM_COMMODITY
        AND GOODS.BL_NBR = BL.NBR
        AND UNIT.GOODS = GOODS.GKEY
        
        AND BL.NBR IN ('COSU6198196460','HPG0139500')
       
;