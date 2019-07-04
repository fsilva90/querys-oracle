select BUSER_USERID, BUSER_AUTH_METHOD, 'Horizon Day: '||HORIZON_DAYS
from SPARCSN4PRD.base_user 
where HORIZON_DAYS > 90
and buser_active = 'Y'     
;