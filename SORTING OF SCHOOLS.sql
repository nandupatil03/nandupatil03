
select * from S6039
select * from S3437

--SEPARATING KARNATAKA LIST FROM FULL LIST
SELECT *,row_number() OVER(ORDER BY UDISE_Code) as SL_NO FROM S6039
where State = 'KARNATAKA'
order by  State;

--SEPARATING KARNATAKA LIST FROM FULL LIST
SELECT *,row_number() OVER(ORDER BY UDISE_Code) as SL_NO FROM S3437
where State = 'KARNATAKA'
order by  State;

--JOINING OF TWO TABLES
select * from S6039 AS S1
FULL OUTER JOIN S3437 as S2
ON S1.State=S2.State

--SEPARATING MORARAJI SCHOOLS FROM LIST
SELECT * FROM S6039
WHERE School_Name  like '%Morarji%' 
and State like '%Karnataka%'

--SEPARATING GOVERNMENT SCHOOLS FROM LIST
SELECT * FROM S6039
WHERE School_Name  like '%Government%' 
and State like '%Karnataka%'

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--FINDING NULL VALUES
SELECT * FROM SS3437
WHERE UDISE_Code IS NULL

--UPDATING NULL VALUES
UPDATE SS3437
SET UDISE_Code = 
  CASE 
    WHEN SL_NO = 5 THEN '29200310599'
    WHEN SL_NO = 8 THEN '29267310599'
    WHEN SL_NO = 12 THEN '29200880599'
    WHEN SL_NO = 20 THEN '2989310599'
    WHEN SL_NO = 22 THEN '29200310669'
  END
WHERE SL_NO IN (5, 8, 12, 20, 22);

--CREATING NEW COLUMN AND CONVERTING LOWER CASES TO UPER CASES
alter table SS3437
add State_new varchar(255) default null;
update  SS3437
set State_new = upper(State)  from SS3437

alter table SS3437
add District_new varchar(255) default null;
update  SS3437
set District_new = upper(District)  from SS3437

--DROPING OF UNWANTED COLUMNS
alter table SS3437
DROP COLUMN F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,F23,F24,F25,F26,State

alter table SS3437
DROP COLUMN District

