DECLARE vStatus INT DEFAULT 0;
vErrorMessage varchar;
vErrorCode INT;
vResult varchar;
vCount INT;
vObject json;
vUserId INT;
vUserEmail character varying;

BEGIN
   vStatus = 0;
   vUserEmail = puseremail;

SELECT
   COUNT(*) into vCount
from
   users where users.email=vUserEmail;
if(vCount > 0 )
then
 SELECT
      json_build_object('status', vStatus, 'result', 'success') INTO vResult;
RETURN vResult;
ELSE
SELECT
json_build_object('status', vCount, 'result', 'fail') INTO vResult;
RETURN vResult;
END IF;

EXCEPTION
WHEN
   OTHERS
THEN
   vErrorCode = 120;
vStatus = - 1;
GET STACKED DIAGNOSTICS vErrorMessage = MESSAGE_TEXT;
SELECT
   json_build_object('status', vStatus, 'error_code', vErrorCode, 'error_msg', vErrorMessage) INTO vResult;
RETURN vResult;
END
