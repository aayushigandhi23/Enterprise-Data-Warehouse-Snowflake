CREATE OR REPLACE FILE FORMAT CSV_SKIP_HEADER
TYPE = 'CSV'
field_delimiter = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
skip_header = 1;


select * from STAGE_CUSTOMER
select * from STAGE_SALESDETAIL

create or replace table DIM_LOCATION (
    DIM_LOCATION_ID  NUMBER(9) IDENTITY(1,1) PRIMARY KEY,
    LOCATION_ADDRESS  VARCHAR(200),
    CITY VARCHAR(100),
    POSTAL_CODE VARCHAR(10),
    STATE_PROVINCE VARCHAR(100),
    COUNTRY VARCHAR(100)
)
DROP TABLE DIM_LOCATION

INSERT INTO DIM_LOCATION (
  DIM_LOCATION_ID,
  LOCATION_ADDRESS,
  CITY,
  POSTAL_CODE,
  STATE_PROVINCE,
  COUNTRY
)
VALUES (-1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN')

INSERT INTO DIM_LOCATION (
  LOCATION_ADDRESS,
  CITY,
  POSTAL_CODE,
  STATE_PROVINCE,
  COUNTRY
)
SELECT ADDRESS, CITY, POSTALCODE, STATEPROVINCE, COUNTRY FROM STAGE_CUSTOMER AS SC
UNION
SELECT ADDRESS, CITY, POSTALCODE, STATEPROVINCE, COUNTRY FROM STAGE_STORE AS SS
UNION
SELECT ADDRESS, CITY, POSTALCODE, STATEPROVINCE, COUNTRY FROM STAGE_RESELLER AS SR


SELECT * FROM DIM_CHANNEL

create or replace table DIM_CHANNEL (
    DIM_CHANNEL_ID NUMBER(10) IDENTITY(1,1) PRIMARY KEY,
    CHANNEL_ID NUMBER(9),
    CHANNEL_CATEGORY_ID NUMBER(9),
    CHANNEL_NAME VARCHAR(200),
    CHANNEL_CATEGORY_NAME VARCHAR(200)
)

INSERT INTO DIM_CHANNEL (
    DIM_CHANNEL_ID,
    CHANNEL_ID,
    CHANNEL_CATEGORY_ID,
    CHANNEL_NAME,
    CHANNEL_CATEGORY_NAME
)
VALUES (-1, -1, -1, 'UNKNOWN', 'UNKNOWN')

INSERT INTO DIM_CHANNEL (
    CHANNEL_ID,
    CHANNEL_CATEGORY_ID,
    CHANNEL_NAME,
    CHANNEL_CATEGORY_NAME
)
SELECT C.CHANNELID, CC.CHANNELCATEGORYID, C.CHANNEL, CC.CHANNELCATEGORY FROM STAGE_CHANNEL AS C
INNER JOIN STAGE_CHANNELCATEGORY AS CC ON C.CHANNELCATEGORYID = CC.CHANNELCATEGORYID

SELECT * FROM STAGE_CHANNELCATEGORY
SELECT * FROM DIM_CHANNEL



CREATE OR REPLACE TABLE DIM_CUSTOMER(
    DIM_CUSTOMER_ID NUMBER(10) IDENTITY(1,1) PRIMARY KEY,
    DIM_LOCATION_ID NUMBER(9) FOREIGN KEY REFERENCES DIM_LOCATION(DIM_LOCATION_ID),
    CUSTOMER_ID VARCHAR(255),
    FULL_NAME VARCHAR(100),
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    GENDER VARCHAR(50),
    EMAIL_ID VARCHAR(255),
    PHONE_NUMBER VARCHAR(20)
)

SELECT * FROM DIM_CUSTOMER

INSERT INTO DIM_CUSTOMER(
    DIM_CUSTOMER_ID,
    DIM_LOCATION_ID,
    CUSTOMER_ID,
    FULL_NAME,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    EMAIL_ID,
    PHONE_NUMBER
)
VALUES (-1, -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNNOWN', 'UNKNOWN', 'UNKNOWN')

INSERT INTO DIM_CUSTOMER(
    CUSTOMER_ID,
    FULL_NAME,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    EMAIL_ID,
    PHONE_NUMBER
)
SELECT CU.CUSTOMERID, CONCAT(CU.FIRSTNAME, '', CU.LASTNAME), CU.FIRSTNAME, CU.LASTNAME, CU.GENDER, CU.EMAILADDRESS, CU.PHONENUMBER FROM STAGE_CUSTOMER AS CU


UPDATE DIM_CUSTOMER AS DCU
SET DCU.DIM_LOCATION_ID = X.DIM_LOCATION_ID
FROM
(SELECT DL.DIM_LOCATION_ID, DCU.CUSTOMER_ID FROM DIM_LOCATION AS DL
INNER JOIN STAGE_CUSTOMER AS SCU ON DL.LOCATION_ADDRESS = SCU.ADDRESS AND DL.CITY = SCU.CITY AND DL.COUNTRY = SCU.COUNTRY
INNER JOIN DIM_CUSTOMER AS DCU ON SCU.CUSTOMERID = DCU.CUSTOMER_ID) X
WHERE DCU.CUSTOMER_ID = X.CUSTOMER_ID
AND DCU.DIM_LOCATION_ID IS NULL

SELECT * FROM DIM_CUSTOMER

CREATE OR REPLACE TABLE DIM_STORE(
    DIM_STORE_ID INT IDENTITY(1,1) PRIMARY KEY,
    DIM_LOCATION_ID NUMBER(9) FOREIGN KEY REFERENCES DIM_LOCATION(DIM_LOCATION_ID),
    STORE_ID NUMBER(10),
    STORE_NUMBER INT,
    STORE_MANAGER VARCHAR(255)
)

INSERT INTO DIM_STORE(
    DIM_STORE_ID,
    DIM_LOCATION_ID,
    STORE_ID,
    STORE_NUMBER,
    STORE_MANAGER
)
VALUES (-1, -1, -1, -1, 'UNKNOWN')

INSERT INTO DIM_STORE(
    STORE_ID,
    STORE_NUMBER,
    STORE_MANAGER
)
SELECT STOREID, STORENUMBER, STOREMANAGER FROM STAGE_STORE

UPDATE DIM_STORE AS DST
SET DST.DIM_LOCATION_ID = Y.DIM_LOCATION_ID
FROM
(SELECT DL.DIM_LOCATION_ID, DST.STORE_ID FROM DIM_LOCATION AS DL
INNER JOIN STAGE_STORE AS SS ON DL.LOCATION_ADDRESS = SS.ADDRESS AND DL.CITY = SS.CITY AND DL.COUNTRY = SS.COUNTRY
INNER JOIN DIM_STORE AS DST ON SS.STOREID = DST.STORE_ID) Y
WHERE DST.STORE_ID = Y.STORE_ID
AND DST.DIM_LOCATION_ID IS NULL

SELECT * FROM DIM_STORE

CREATE OR REPLACE TABLE DIM_RESELLER(
    DIM_RESELLER_ID INT IDENTITY(1,1) PRIMARY KEY,
    DIM_LOCATION_ID NUMBER(9) FOREIGN KEY REFERENCES DIM_LOCATION(DIM_LOCATION_ID),
    RESELLER_ID VARCHAR(255),
    RESELLER_NAME VARCHAR(255),
    RESELLER_CONTACT VARCHAR(255),
    PHONE_NUMBER VARCHAR(20),
    EMAIL VARCHAR(255)
)

INSERT INTO DIM_RESELLER(
    DIM_RESELLER_ID,
    DIM_LOCATION_ID,
    RESELLER_ID,
    RESELLER_NAME,
    RESELLER_CONTACT,
    PHONE_NUMBER,
    EMAIL
)
VALUES (-1, -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN')

INSERT INTO DIM_RESELLER(
    RESELLER_ID,
    RESELLER_NAME,
    RESELLER_CONTACT,
    PHONE_NUMBER,
    EMAIL
)
SELECT RESELLERID, RESELLERNAME, CONTACT, PHONENUMBER, EMAILADDRESS FROM STAGE_RESELLER

UPDATE DIM_RESELLER AS DR
SET DR.DIM_LOCATION_ID = Z.DIM_LOCATION_ID
FROM
(
  SELECT DL.DIM_LOCATION_ID, DR.RESELLER_ID FROM DIM_LOCATION AS DL
  INNER JOIN STAGE_RESELLER AS SR ON DL.LOCATION_ADDRESS = SR.ADDRESS AND DL.CITY = SR.CITY AND DL.COUNTRY = SR.COUNTRY
  INNER JOIN DIM_RESELLER AS DR ON SR.RESELLERID = DR.RESELLER_ID
) Z
WHERE DR.RESELLER_ID = Z.RESELLER_ID
AND DR.DIM_LOCATION_ID IS NULL

SELECT * FROM DIM_RESELLER

CREATE OR REPLACE TABLE DIM_PRODUCT(
    DIM_PRODUCT_ID INT IDENTITY(1,1) PRIMARY KEY,
    PRODUCT_ID INT,
    PRODUCT_TYPE_ID INT,
    PRODUCT_CATEGORY_ID INT,
    PRODUCT_NAME VARCHAR(255),
    PRODUCT_TYPE VARCHAR(255),
    PRODUCT_CATEGORY VARCHAR(255),
    PRODUCT_RETAIL_PRICE NUMBER(8,2),
    PRODUCT_WHOLESALE_PRICE NUMBER(8,2),
    PRODUCT_COST NUMBER(8,2),
    PRODUCT_RETAIL_PROFIT NUMBER(8,2),
    PRODUCT_WHOLESALE_UNIT_PROFIT NUMBER(8,2),
    PRODUCT_RPROFIT_MARGIN_UNIT_PERCENT NUMBER(8,2),
    PRODUCT_WPROFIT_MARGIN_UNIT_PERCENT NUMBER(8,2)
)

INSERT INTO DIM_PRODUCT(
    DIM_PRODUCT_ID,
    PRODUCT_ID,
    PRODUCT_TYPE_ID,
    PRODUCT_CATEGORY_ID,
    PRODUCT_NAME,
    PRODUCT_TYPE,
    PRODUCT_CATEGORY,
    PRODUCT_RETAIL_PRICE,
    PRODUCT_WHOLESALE_PRICE,
    PRODUCT_COST,
    PRODUCT_RETAIL_PROFIT,
    PRODUCT_WHOLESALE_UNIT_PROFIT,
    PRODUCT_RPROFIT_MARGIN_UNIT_PERCENT,
    PRODUCT_WPROFIT_MARGIN_UNIT_PERCENT
)
VALUES (-1, -1, -1, -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', -1, -1, -1, -1, -1, -1, -1)

SELECT * FROM DIM_PRODUCT

INSERT INTO DIM_PRODUCT(
    PRODUCT_ID,
    PRODUCT_TYPE_ID,
    PRODUCT_CATEGORY_ID,
    PRODUCT_NAME,
    PRODUCT_TYPE,
    PRODUCT_CATEGORY,
    PRODUCT_RETAIL_PRICE,
    PRODUCT_WHOLESALE_PRICE,
    PRODUCT_COST,
    PRODUCT_RETAIL_PROFIT,
    PRODUCT_WHOLESALE_UNIT_PROFIT,
    PRODUCT_RPROFIT_MARGIN_UNIT_PERCENT,
    PRODUCT_WPROFIT_MARGIN_UNIT_PERCENT
)
SELECT P.PRODUCTID, PT.PRODUCTTYPEID, PC.PRODUCTCATEGORYID, P.PRODUCT, 
PT.PRODUCTTYPE, PC.PRODUCTCATEGORY, P.PRICE, P.WHOLESALEPRICE, P.COST, (P.PRICE - P.COST), (P.WHOLESALEPRICE - P.COST), (P.PRICE - P.COST)*100/P.PRICE, (P.WHOLESALEPRICE - P.COST)*100/P.PRICE
FROM STAGE_PRODUCT AS P
INNER JOIN STAGE_PRODUCTTYPE AS PT ON P.PRODUCTTYPEID = PT.PRODUCTTYPEID
INNER JOIN STAGE_PRODUCTCATEGORY AS PC ON PT.PRODUCTCATEGORYID = PC.PRODUCTCATEGORYID

CREATE OR REPLACE TABLE FACT_SALES (
  SALESHEADER_ID INT NOT NULL,
  SALESDETAIL_ID INT NOT NULL,
  DIM_PRODUCT_ID INT CONSTRAINT FK_PRODUCT_ID FOREIGN KEY REFERENCES DIM_PRODUCT(DIM_PRODUCT_ID),
  DIM_STORE_ID INT CONSTRAINT FK_STORE_ID FOREIGN KEY REFERENCES DIM_STORE(DIM_STORE_ID),
  DIM_RESELLER_ID INT CONSTRAINT FK_RESELLER_ID FOREIGN KEY REFERENCES DIM_RESELLER(DIM_RESELLER_ID),
  DIM_CUSTOMER_ID NUMBER(10) CONSTRAINT FK_CUSTOMER_ID FOREIGN KEY REFERENCES DIM_CUSTOMER(DIM_CUSTOMER_ID),
  DIM_CHANNEL_ID NUMBER(10) CONSTRAINT FK_CHANNEL_ID FOREIGN KEY REFERENCES DIM_CHANNEL(DIM_CHANNEL_ID),
  DATE_PKEY NUMBER(9) CONSTRAINT FK_DATE FOREIGN KEY REFERENCES DIM_DATE(DATE_PKEY),
  DIM_LOCATION_ID NUMBER(9) CONSTRAINT FK_LOCATION_ID FOREIGN KEY REFERENCES DIM_LOCATION(DIM_LOCATION_ID),
  SALE_AMOUNT NUMBER(8,2),
  SALE_QUANTITY INT,
  SALE_UNIT_PRICE NUMBER(8,2),
  SALE_EXTENDED_COST NUMBER(8,2),
  SALE_TOTAL_PROFIT NUMBER(8,2)
)

INSERT INTO FACT_SALES(
  SALESHEADER_ID,
  SALESDETAIL_ID,
  DIM_PRODUCT_ID,
  DIM_STORE_ID,
  DIM_RESELLER_ID,
  DIM_CUSTOMER_ID,
  DIM_CHANNEL_ID,
  DATE_PKEY,
  DIM_LOCATION_ID,
  SALE_AMOUNT,
  SALE_QUANTITY,
  SALE_UNIT_PRICE,
  SALE_EXTENDED_COST,
  SALE_TOTAL_PROFIT
)
SELECT SH.SALESHEADERID,
       SD.SALESDETAILID,
       DP.DIM_PRODUCT_ID,
       NVL(DS.DIM_STORE_ID, -1) AS DIM_STORE_ID,
       NVL(DR.DIM_RESELLER_ID, -1) AS DIM_RESELLER_ID,
       NVL(DC.DIM_CUSTOMER_ID, -1) AS DIM_CUSTOMER_ID,
       DCH.DIM_CHANNEL_ID,
       CAST(REPLACE(REPLACE(CAST(SH.DATE AS DATE), '00', '20'), '-', '') AS NUMBER(9)) AS DATE_PKEY,
       COALESCE(DS.DIM_LOCATION_ID, DC.DIM_LOCATION_ID, DR.DIM_LOCATION_ID, -1) AS DIM_LOCATION_ID,
       SD.SALESAMOUNT,
       SD.SALESQUANTITY,
       CASE WHEN DR.DIM_RESELLER_ID IS NOT NULL THEN DP.PRODUCT_WHOLESALE_PRICE ELSE DP.PRODUCT_RETAIL_PRICE END AS SALE_UNIT_PRICE,
       ROUND(DP.PRODUCT_COST* SALESQUANTITY,2) as SALE_EXTENDED_COST,
       SALE_UNIT_PRICE - DP.PRODUCT_COST AS SALE_TOTAL_PROFIT
FROM STAGE_SALESHEADER AS SH
INNER JOIN STAGE_SALESDETAIL AS SD ON SH.SALESHEADERID = SD.SALESHEADERID
INNER JOIN DIM_PRODUCT AS DP ON SD.PRODUCTID = DP.DIM_PRODUCT_ID
INNER JOIN DIM_CHANNEL AS DCH ON SH.CHANNELID = DCH.DIM_CHANNEL_ID
LEFT JOIN DIM_STORE AS DS ON SH.STOREID = DS.DIM_STORE_ID
LEFT JOIN DIM_RESELLER AS DR ON SH.RESELLERID = DR.RESELLER_ID
LEFT JOIN DIM_CUSTOMER AS DC ON SH.CUSTOMERID = DC.CUSTOMER_ID
  
  
  
DROP TABLE FACT_SALES
select * from fact_sales



CREATE OR REPLACE TABLE FACT_PRODUCT_SALES_TARGET(
  DIM_PRODUCT_ID INT CONSTRAINT FK_PROD_ID FOREIGN KEY REFERENCES DIM_PRODUCT(DIM_PRODUCT_ID),
  DATE_PKEY NUMBER(9) CONSTRAINT FK_DATEKEY FOREIGN KEY REFERENCES DIM_DATE(DATE_PKEY),
  PRODUCT_TARGET_SALES_QUANTITY NUMBER(8,2)
)

INSERT INTO FACT_PRODUCT_SALES_TARGET(
  DIM_PRODUCT_ID,
  DATE_PKEY,
  PRODUCT_TARGET_SALES_QUANTITY
)
SELECT DP.DIM_PRODUCT_ID, DD.DATE_PKEY, ROUND(STDP.SALESQUANTITYTARGET/365, 2) AS PRODUCT_TARGET_SALES_QUANTITY
FROM DIM_PRODUCT AS DP 
INNER JOIN STAGE_TARGETDATAPRODUCT AS STDP ON DP.DIM_PRODUCT_ID = STDP.PRODUCTID
INNER JOIN DIM_DATE AS DD ON STDP.YEAR = DD.YEAR


select * from FACT_PRODUCT_SALES_TARGET

CREATE OR REPLACE TABLE FACT_SRC_SALES_TARGET(
  DIM_STORE_ID INT CONSTRAINT FK_STR_ID FOREIGN KEY REFERENCES DIM_STORE(DIM_STORE_ID),
  DIM_RESELLER_ID INT CONSTRAINT FK_RESELL_ID FOREIGN KEY REFERENCES DIM_RESELLER(DIM_RESELLER_ID),
  DIM_CHANNEL_ID NUMBER(10) CONSTRAINT FK_CHNNL_ID FOREIGN KEY REFERENCES DIM_CHANNEL(DIM_CHANNEL_ID),
  DATE_PKEY NUMBER(9) CONSTRAINT FK_DATEID FOREIGN KEY REFERENCES DIM_DATE(DATE_PKEY),
  SALES_TARGET_AMOUNT NUMBER(15,2)
)

INSERT INTO FACT_SRC_SALES_TARGET(
  DIM_STORE_ID,
  DIM_RESELLER_ID,
  DIM_CHANNEL_ID,
  DATE_PKEY,
  SALES_TARGET_AMOUNT
)
SELECT NVL(DS.DIM_STORE_ID, -1) AS DIM_STORE_ID,
       NVL(DR.DIM_RESELLER_ID, -1) AS DIM_RESELLER_ID,
       DCH.DIM_CHANNEL_ID,
       DD.DATE_PKEY,
        NVL(ROUND(STDC.TARGETSALESAMOUNT/365,2), -1) AS SALES_TARGET_AMOUNT
FROM STAGE_TARGETDATACHANNEL AS STDC
LEFT JOIN DIM_STORE AS DS ON DS.STORE_NUMBER = CASE WHEN STDC.TARGETNAME = 'Store Number 5' THEN 5
                                                                        WHEN STDC.TARGETNAME = 'Store Number 8' THEN 8
                                                                        WHEN STDC.TARGETNAME = 'Store Number 10' THEN 10
                                                                        WHEN STDC.TARGETNAME = 'Store Number 21' THEN 21
                                                                        WHEN STDC.TARGETNAME = 'Store Number 34' THEN 34
                                                                        WHEN STDC.TARGETNAME = 'Store Number 39' THEN 39 END
LEFT JOIN DIM_RESELLER AS DR ON DR.RESELLER_NAME = STDC.TARGETNAME
INNER JOIN DIM_CHANNEL AS DCH ON DCH.CHANNEL_NAME = CASE WHEN STDC.CHANNELNAME = 'Online' THEN 'On-line' ELSE STDC.CHANNELNAME END
LEFT JOIN DIM_DATE AS DD ON STDC.YEAR = DD.YEAR


select * from FACT_SRC_SALES_TARGET


select a.*, b.* from STAGE_TARGETDATACHANNEL as a
inner join DIM_RESELLER AS b on a.TARGETNAME = b.RESELLER_NAME

SELECT TARGETNAME, TRIM(TARGETNAME), REPLACE(TARGETNAME,' ','') FROM STAGE_TARGETDATACHANNEL
'Indiana Department Store'

SELECT * FROM DIM_RESELLER 

SELECT * FROM STAGE_TARGETDATACHANNEL AS STDC


'Mississipi Distributors'
'Walmart Supercenter'
'Indiana Department Store' '
Indiana Department Store'
'Georgia Mega Store'

select YEAR, CHANNELNAME, CAST(SUBSTRING(STDC.TARGETNAME, 13, LEN(STDC.TARGETNAME)) AS INT), TARGETSALESAMOUNT
from STAGE_TARGETDATACHANNEL AS STDC where TARGETNAME LIKE 'Store Number%'