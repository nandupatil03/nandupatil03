/*
CLEANING DATA IN SQL QUERIES
*/

--------------------------------------------------------------------------------------------------------------------------------
--1.STANDARDIZE DATE FORMATE (BREAKDOWN OF DATE TIME COLUMN TO DATE)
alter table housing
add Sale_Date date;

update housing --(AS THERE IS BOTH DATE AND TIME, SO TO REMOVE TIME WE USE CONVERT DATE)
set Sale_Date = convert(date ,SaleDate)

--------------------------------------------------------------------------------------------------------------------------------
--2.POPUATE(INSERTING) PROPERTY ADRESS DATA
--ALL HAVE DIFFERENT UNIQUE ID BUT THOSE WHO HAVE SAME PARCELID HAVE SAME ADDRESS, SO SOME SAME PARCELID'S ARE HAVING NULL ADDRESS BY WHICH BELOW QUERY WE WILL INSERT DATA TO NULL ROWS0
select * from housing
where PropertyAddress is null

select h1.[UniqueID ],h2.[UniqueID ], h1.ParcelID,h1.PropertyAddress,h2.ParcelID,h2.PropertyAddress,isnull(h1.PropertyAddress,h2.PropertyAddress) from housing as h1
join housing h2
on h1.ParcelID=h2.ParcelID
and h1.[UniqueID ] != h2.[UniqueID ]
where h1.PropertyAddress is null

update h1 --(WE SHOULD ONLY USE ALIASES IN UPDATE AFTER JOINS)
set PropertyAddress = isnull(h1.PropertyAddress,h2.PropertyAddress)
from housing as h1
join housing h2
on h1.ParcelID=h2.ParcelID
and h1.[UniqueID ] != h2.[UniqueID ]
where h1.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------
--3.BREAKING ADDRESS INTO INDIVIDUAL COLUMN (AREA,CITY,STATE)

select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress )-1) as address1,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))as address2
from housing;

alter table housing --(ADDING NEW COLUMN ADRESS_CITY WHERE FURTHER PROCEESED DATA IS UPDATED TO IT)
add  adress_city nvarchar(255) ;

update housing
set adress_city = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress )-1);

alter table housing
add  adress_state nvarchar(255) ;

update housing
set adress_state = substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------------
--4.BREAKDOWN OF OWNER ADDRESS:
--(PARSNAME IS INSTEAD OF SUBSTRING TO SPLIT COLUMN,PARSNAME IS EFFCIENT AND EASIER THEN SUBSTRING)
--(PARSENAME READS ONLY PERIOS(.) SO FIRST WE REPLACED (,) BY (.))
--(PARSENAME READS COLUMNS BACKWARDS SO WE GIVEN 1,2,3 AS 3,2,1 TO GET ORDER WISE COLUMNS)
select PARSENAME(replace (OwnerAddress, ',','.'),3),
PARSENAME(replace (OwnerAddress, ',','.'),2),
PARSENAME(replace (OwnerAddress, ',','.'),1)
from housing

alter table housing 
add  owner_house nvarchar(255) ;

update housing
set owner_house = PARSENAME(replace (OwnerAddress, ',','.'),3);

alter table housing
add  owner_city nvarchar(255) ;

update housing
set owner_city = PARSENAME(replace (OwnerAddress, ',','.'),2);

alter table housing
add  owner_state nvarchar(255) ;

update housing
set owner_state = PARSENAME(replace (OwnerAddress, ',','.'),1);

--------------------------------------------------------------------------------------------------------------------------------
--5.CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT FIELD"

select distinct(SoldAsVacant),count(SoldAsVacant) from housing
--select SoldAsVacant,count(SoldAsVacant) from housing
group by SoldAsVacant
order by SoldAsVacant

--USING CASE STATMENT
select SoldAsVacant, 
case
when SoldAsVacant = 'Y' then 'YES'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end
from housing

--UPDATE IS WORKING HERE WITHOUT ADDING A COLUMN BEFORE,IF NOT USE ALTER TABLE TO ADD COLUMN AND THEN UPDATE IT
update housing
set SoldAsVacant = 
case
when SoldAsVacant = 'Y' then 'YES'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end

------------------------------------------------------------------------------------------------------------------------------
--6.REMOVE DUPLICATES FOR ONLY  TEMP TABLE
--WE ARE USING TEMP TABLES AS WINDOWS FUNCTION CANNOT BE USED DIRECTLY IN UPDATE )
--ROW_NUMBER ( ACTS DIFFERENT FOR PARTITION BY AND ORDER BY)	

drop table if exists #rownum_1
create table #rownum_1
(ParcelID nvarchar(255),
PropertyAddress nvarchar(255), 
SalePrice float, 
SaleDate datetime, 
LegalReference nvarchar(255), 
UniqueID float,
row_number1 int
)

INSERT INTO #rownum_1 (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID, row_number1)
    SELECT 
        ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_number1
    FROM housing

delete from #rownum_1
where row_number1>1

DELETE FROM housing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM #rownum_1
    WHERE row_number1 > 1
);



------------------------------------------------------------------------------------------------------------------------------
--7.DISPLAY OF NON-DUPLICATE ROWS BASED ON ParcelID
select ParcelID,[UniqueID ] from housing
WHERE ParcelID in (
    SELECT ParcelID
    FROM housing
    GROUP BY ParcelID
    HAVING COUNT(*) = 1
);

------------------------------------------------------------------------------------------------------------------------------
--8.DELETE UNUSED COLUMNS

alter table housing
drop column PropertyAddress,OwnerName,OwnerAddress

alter table housing
drop column SaleDate


------------------------------------------------------------------------------------------------------------------------------