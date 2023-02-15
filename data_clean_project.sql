update nash_house
set SaleDate = CONVERT(Date, SaleDate);

select SaleDate
from nash_house;



-- populate property address

select ParcelID, PropertyAddress
from nash_house
order by ParcelID;

with fulladdress as(
select distinct ParcelID, PropertyAddress
from nash_house
where PropertyAddress is not null)


update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from nash_house as a
left join fulladdress as b
on a.ParcelID = b.ParcelID

select PropertyAddress from nash_house
where PropertyAddress is null;


-- Breaking out address into individual columns (Address, City, State)

select PropertyAddress from nash_house
order by ParcelID;

select
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from nash_house;

alter table nash_house
add AddressDetail Nvarchar(255);

update nash_house
set AddressDetail = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table nash_house
add City Nvarchar(255);

update nash_house
set City = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

select * from nash_house;

select OwnerAddress from nash_house;

select PARSENAME(replace(OwnerAddress, ',','.'),3),
PARSENAME(replace(OwnerAddress, ',','.'),2),
PARSENAME(replace(OwnerAddress, ',','.'),1)
from nash_house

alter table nash_house
add OwnerAddressDetail Nvarchar(255);

update nash_house
set OwnerAddressDetail = PARSENAME(replace(OwnerAddress, ',','.'),3)

alter table nash_house
add OwnerCity Nvarchar(255);

update nash_house
set OwnerCity = PARSENAME(replace(OwnerAddress, ',','.'),2)

alter table nash_house
add OwnerState Nvarchar(255);

update nash_house
set OwnerState = PARSENAME(replace(OwnerAddress, ',','.'),1)

select * from nash_house;


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct SoldAsVacant from nash_house;



update nash_house
set SoldAsVacant = case when SoldAsVacant = 'Y' then 1
	when SoldAsVacant = 'N' then 0
	end


-- Remove Duplicates
with Row_NumCTE as (
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from nash_house
)

delete
from Row_NumCTE
where row_num > 1;

select * from nash_house;


-- Delete Unused Columns
alter table nash_house
drop column OwnerAddress, TaxDistrict, PropertyAddress;

select * from nash_house;

alter table nash_house
drop column SaleDate;

