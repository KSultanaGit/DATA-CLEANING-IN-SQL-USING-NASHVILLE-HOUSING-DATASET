

#Cleaning Data in SQL


Select *
From NashvilleHousing;

-- ------------------------------------------------------------------------------------------------------------------------

-- 1. Standardize Date Format---------------------------------------------------------------------------------------------


Select saleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing;


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);


 -- ------------------------------------------------------------------------------------------------------------------------

-- 2. Populate Property Address data----------------------------------------------------------------------------------------

-- checking for null rows ---------------------------------------
Select *
From NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID;


-- checking appropriate values for updation-----------------------
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

-- Updating in the table----------------------------------------------------------------
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. Breaking out Address into Individual Columns (Address, City, State)-------------------------------------------------------------------------------------------


Select PropertyAddress
From NashvilleHousing;

-- extracting the first value before comma from property address------------------------------------------


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing;


-- add column to table----------------------------------------------------------

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

-- update the new column values--------------------------------------------------

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

-- add column to table----------------------------------------------------------

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

-- update the new column values--------------------------------------------------

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

-- --------------------------------------------------------------------------------
Select *
From NashvilleHousing;


Select OwnerAddress
From NashvilleHousing;


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing;


-- add column to table----------------------------------------------------------
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

-- update the new column values--------------------------------------------------
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

-- add column to table----------------------------------------------------------
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);


-- update the new column values--------------------------------------------------
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);


-- add column to table----------------------------------------------------------
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
-- update the new column values--------------------------------------------------
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);


# viewing the updated columns
Select *
From NashvilleHousing;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4. Change Y and N to Yes and No in "Sold as Vacant" field-------------------------------------------------------------------------------------------------------------------------

# checking sold as vacant values
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2;

# checking sold as vacant values and updating with case statement
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing;

#updating values
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6. Remove Duplicates-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#selecting rows that have count more than 1
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

Select *
From NashvilleHousing;

--  -----------------------------------------------------------------------------------------------------------------------------------------

-- 7. Delete Unused Columns----------------------------------------------------------------------------------------------------------------

Select *
From NashvilleHousing;

#dropping unnecessary columns
ALTER TABLE NashvilleHousing
			DROP COLUMN OwnerAddress;
ALTER TABLE NashvilleHousing
			DROP COLUMN TaxDistrict;
ALTER TABLE NashvilleHousing
			DROP COLUMN PropertyAddress, SaleDate;



 
