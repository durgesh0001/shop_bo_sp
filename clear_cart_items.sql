DECLARE vStatus INT DEFAULT 0;
vErrorMessage varchar;
vErrorCode INT;
vResult varchar;
vCount INT;
vUserId INT;

BEGIN
   vStatus = 0;
   vUserId = puserid;
SELECT
   count(*) into vCount
from
  cart where cart.user_id = vUserId;

IF(vCount <  1 )
then
   SELECT  json_build_object('status', vStatus, 'result', 'fail') INTO vResult;
   RETURN vResult;
ELSE
   delete from cart where cart.user_id = vUserId;
   SELECT  json_build_object('status', vStatus, 'result', 'success') INTO vResult;

END IF;
RETURN vResult;
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
