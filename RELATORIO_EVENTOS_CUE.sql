SELECT -- CASE WHEN jobname = 'Analyst' THEN 1 ELSE 0 END AS IsAnalyst
    A.IB_ID,
    A.CUE   CUE,
    B.IMP   IMP,
    SUM( A.CUE - B.IMP) AS DIF
/*    CASE
        WHEN 
            SUM( A.CUE - B.IMP) < 0  THEN SUM (B.IMP + 0)
        ELSE
            SUM( A.CUE - B.IMP) 
   END AS DIF
*/
FROM
    (
        SELECT
            CUE.IB_ID,
            COUNT(CUE.IB_ID) AS CUE
        FROM
            SPARCSN4PRD.ARGO_AR_CHARGEABLE_UNIT_EVENTS CUE
        WHERE
            CUE.EVENT_TYPE = 'UNIT_DISCH' -- TOTAL 5318
            AND ( CUE.UFV_TIME_IN >= TO_DATE('01/01/2018 00:00:00', 'DD/MM/YYYY HH24:MI:SS')
                  AND CUE.UFV_TIME_IN <= TO_DATE('31/08/2018 23:59:59', 'DD/MM/YYYY HH24:MI:SS') )
            --AND ROWNUM <= 1000000
        GROUP BY
            CUE.IB_ID
        ORDER BY
            CUE.IB_ID
    ) A,
    (
        SELECT
            CUE.IB_ID,
            COUNT(CUE.IB_ID) AS IMP
        FROM
            SPARCSN4PRD.ARGO_AR_CHARGEABLE_UNIT_EVENTS CUE
        WHERE
            CUE.EVENT_TYPE = 'UNIT_DISCH'
            AND CUE.CATEGORY = 'IMPRT'
            AND CUE.FREIGHT_KIND IN (
                'FCL',
                'LCL'
            )
            AND ( CUE.UFV_TIME_IN >= TO_DATE('01/01/2018 00:00:00', 'DD/MM/YYYY HH24:MI:SS')
                  AND CUE.UFV_TIME_IN <= TO_DATE('31/08/2018 23:59:59', 'DD/MM/YYYY HH24:MI:SS') )
            --AND ROWNUM <= 1000000
        GROUP BY
            CUE.IB_ID
        ORDER BY
            CUE.IB_ID
    ) B
WHERE
    A.IB_ID = B.IB_ID
GROUP BY
    A.IB_ID,
    A.CUE,
    B.IMP
ORDER BY
    A.IB_ID;