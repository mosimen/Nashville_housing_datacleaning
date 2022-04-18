use portfolio_project

select *
from NashvilleHousing

---Standardize the SaleDate
select 
	cast(SaleDate as date)
from NashvilleHousing
--We see that the SaleDate data is in datetime format, we want to convert it to date format

--Add a new column with the right datatype to the housing table, then set it to the SaleDate data
alter table [dbo].[NashvilleHousing]
add sales_date date;

update NashvilleHousing
set sales_date = cast(SaleDate as date)

--We see that the new column (sales_date) is now in the desired data type
select SaleDate, sales_date
from NashvilleHousing

---Split the PropertyAddress data into Address, City and State
select PropertyAddress
from NashvilleHousing

--Check for Nulls in the data
select PropertyAddress
from NashvilleHousing
where PropertyAddress is null
--We see null values in the PropertyAddress column

select *
from NashvilleHousing
order by ParcelID
---But we notice that the same ParcelID has same PropertyAddress, we need to fill the null values

--We will join the dataset with itself inorder to fill the null values
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


select *
from NashvilleHousing
where PropertyAddress is null

---Splitting PropertyAddress into Address, City, State. Let us use the Substring method
select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);
update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)
update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from NashvilleHousing


--Extracting Address, City and State from OwnerAddress column but we will not use substring this time. Let us try the PARSENAME method
select *
from NashvilleHousing
-- OwnerAddress is null

---PARSENAME method
select
PARSENAME(replace(OwnerAddress, ',', '.'),3) as owner_address,
PARSENAME(replace(OwnerAddress, ',', '.'),2) as owner_city,
PARSENAME(replace(OwnerAddress, ',', '.'),1) as owner_state

from NashvilleHousing
where OwnerAddress is not null

alter table [dbo].[NashvilleHousing]
add owner_address nvarchar(255)
update NashvilleHousing
set owner_address = PARSENAME(replace(OwnerAddress, ',', '.'),3)

alter table [dbo].[NashvilleHousing]
add owner_city nvarchar(255)
update NashvilleHousing
set owner_city = PARSENAME(replace(OwnerAddress, ',', '.'),2)

alter table [dbo].[NashvilleHousing]
add owner_state nvarchar(255)
update NashvilleHousing
set owner_state = PARSENAME(replace(OwnerAddress, ',', '.'),1)

---
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
--We need to replace y with Yes and N with No

select SoldAsVacant,
	case 
	when SoldAsVacant ='Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
	when SoldAsVacant ='Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

---Removing Duplicate data
; with cte as
(
select *,
	ROW_NUMBER() over (
	partition by
		ParcelID,
		PropertyAddress,
		SaleDate,
		LegalReference
	order by
		UniqueID) row_num
			
from NashvilleHousing
)
delete
from cte
where row_num>1


--Deleting unused columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column SaleDate,PropertyAddress,OwnerAddress, TaxDistrict





