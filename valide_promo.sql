DECLARE vStatus INT DEFAULT 0;
vErrorMessage varchar;
vErrorCode INT;
vResult varchar;
vCount INT;
vObject json;
vUserId INT;
vPromo character varying;
vAmount double precision;
vDiscount double precision;
vDiscountAmountdocgen double precision;
vDiscountAmountdocgenTotal double precision;
vDiscountAmountFormTotal double precision;


vDiscountAmountwf double precision;
vCartCount INT;
vdocgenCount INT;
vwfCount INT;
vformCount INT;
vDiscountAmountform INT;
cartDetails json;
vtotalAmount double precision;
BEGIN
   vStatus = 0;
   vUserId = puserid;
   vPromo = ppromo;
SELECT
   count(*) into vCount
from
   promocodes where promo_code_name=vPromo;
   SELECT SUM(products.price) into vAmount
   FROM products
   INNER JOIN cart ON products.id=cart.product_id where cart.user_id = vUserId;

    SELECT SUM(products.price) into vtotalAmount
      FROM products
      INNER JOIN cart ON products.id=cart.product_id where cart.user_id = vUserId;



   SELECT
      to_json(array_agg(temp)) INTO cartDetails
   FROM
      (
        SELECT products.price,products.product_name,products.product_id FROM products INNER JOIN cart ON products.id=cart.product_id where cart.user_id = vUserId
      )
      temp;



 if (vAmount is null) then
     vAmount = 0;
  end if;

   if (vtotalAmount is null) then
       vtotalAmount = 0;
    end if;

IF(cartDetails is null) then
cartDetails ='[]';
END IF;

 IF(vPromo is null or vPromo = '')
 then
   SELECT  json_build_object('status', vStatus, 'result', json_build_object('cartdetails',cartDetails,'totalAmountWithPromoDiscount',vAmount,'totalAmount',vtotalAmount)) INTO vResult;
    RETURN vResult;
 END IF;

IF(vCount <  1 )
then
   SELECT  json_build_object('status', vStatus, 'result', 'fail') INTO vResult;
   RETURN vResult;
ELSE

SELECT
   count(*) into vCount
from
   checkout where promocode=vPromo and user_id= vUserId;

   IF(vCount >  0 )
then
   SELECT  json_build_object('status', vStatus, 'result', 'used') INTO vResult;
   RETURN vResult;
   end if;


IF(vPromo = 'RRD4D32') THEN
   if (vAmount is null) then
          vAmount = 0;
   end if;

   IF (vAmount > 1000) THEN
   vDiscount = vAmount * 10/100;
   vAmount = vAmount - vDiscount;
   INSERT INTO checkout(user_id,promocode) VALUES (vUserId, vPromo);
   END IF;

 ELSEIF(vPromo = '44F4T11') THEN
      if (vAmount is null) then
          vAmount = 0;
       end if;

      IF (vAmount > 1500) THEN
      vDiscount = vAmount * 15/100;
      vAmount = vAmount - vDiscount;
	   INSERT INTO checkout(user_id,promocode) VALUES (vUserId, vPromo);
      END IF;

 ELSEIF(vPromo = 'FF9543D1') THEN
      SELECT COUNT(*) into vdocgenCount from cart where user_id = vUserId and product_id in ( select id from products where product_id='docgen');
       SELECT SUM(products.price -1) into vDiscountAmountdocgen FROM products INNER JOIN cart ON products.id=cart.product_id where cart.user_id = vUserId and products.product_id='docgen';
        if (vDiscountAmountdocgen is null) then
                      vDiscountAmountdocgen = 0;
          end if;
      if(vdocgenCount >= 10) then
       SELECT SUM(products.price) into vAmount FROM products INNER JOIN cart ON products.id=cart.product_id where cart.user_id = vUserId and products.product_id !='docgen';
            if (vAmount is null) then
                vAmount = 0;
             end if;
             vAmount = vAmount + vDiscountAmountdocgen;
			  INSERT INTO checkout(user_id,promocode) VALUES (vUserId, vPromo);
      end if;
ELSEIF(vPromo = 'YYGWKJD') THEN
   SELECT SUM(products.price -10) into vDiscountAmountform FROM products INNER JOIN cart ON products.id=cart.product_id where cart.user_id = vUserId and products.product_id='form';
   SELECT COUNT(*) into vwfCount from cart where user_id = vUserId and product_id in ( select id from products where product_id='wf');
   if (vDiscountAmountform is null) then
                        vDiscountAmountform = 0;
      end if;

      if(vwfCount >= 1) then

          SELECT SUM(products.price) into vAmount FROM products INNER JOIN cart ON products.id=cart.product_id where cart.user_id = vUserId and products.product_id !='form';
                  if (vAmount is null) then
                      vAmount = 0;
                   end if;
             vAmount = vAmount + vDiscountAmountform;
			 INSERT INTO checkout(user_id,promocode) VALUES (vUserId, vPromo);
      end if;
END IF;
END IF;

SELECT  json_build_object('status', vStatus, 'result', json_build_object('cartdetails',cartDetails,'totalAmountWithPromoDiscount',vAmount,'totalAmount',vtotalAmount)) INTO vResult;
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
