DECLARE vStatus INT DEFAULT 0;
vErrorMessage varchar;
vErrorCode INT;
vResult varchar;
vCount INT;
vObject json;
BEGIN
   vStatus = 0;
SELECT
   count(*) into vCount
from
   products;
if(vCount < 1)
then
   SELECT
      json_build_object('status', vStatus, 'result', 'fail') INTO vResult;
RETURN vResult;
ELSE
-- this works
SELECT
   to_json(array_agg(temp)) INTO vObject
FROM
   (
      SELECT
         *
      from
         products
   )
   temp;
END
IF;
SELECT
   json_build_object('status', vStatus, 'result', vObject) INTO vResult;
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
