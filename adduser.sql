DECLARE vStatus INT DEFAULT 0;
vErrorMessage varchar;
vErrorCode INT;
vResult varchar;
vCount INT;
vObject json;
vUserId INT;
vProductId INT;
vUserEmail character varying;
vUserName character varying;
vUserPasswrod character varying;
vUserAddress text;
vUserActive int;

BEGIN
   vStatus = 0;
   vUserEmail = puseremail;
   vUserName = pname;
   vUserPasswrod = ppassword;
   vUserAddress= paddress;
   vUserActive = 1;

SELECT
   count(*) into vCount
from
   users where email=vUserEmail;
if(vCount > 0 )
then
 SELECT
      json_build_object('status', vStatus, 'result', 'fail') INTO vResult;
RETURN vResult;
ELSE
INSERT INTO users(email,name,password,is_active,address) VALUES (vUserEmail,vUserName,vUserPasswrod,vUserActive,vUserAddress);
END IF;
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
