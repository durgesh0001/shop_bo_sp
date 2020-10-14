DECLARE vStatus INT DEFAULT 0;
vErrorMessage varchar;
vErrorCode INT;
vResult varchar;
vCount INT;
vObject json;
vUserId INT;
vProductId INT;


BEGIN
   vStatus = 0;
   vUserId = puserid;
   vProductId = pproductid;
SELECT
   count(*) into vCount
from
   products where id=vProductId;
if(vCount < 1 )
then
   SELECT
      json_build_object('status', vStatus, 'result', 'fail') INTO vResult;
RETURN vResult;
ELSE
INSERT INTO cart (user_id, product_id)
VALUES (vUserId, vProductId);
END
IF;
SELECT
json_build_object('status', vStatus, 'result', 'success') INTO vResult;
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
