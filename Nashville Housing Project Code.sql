/*
Cleaning Data with SQL Queries
*/

SELECT *
FROM project1.dbo.NashvilleHousing


--Populate Property Address Data

SELECT *
FROM project1.dbo.NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID,
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project1.dbo.NashvilleHousing a
JOIN project1.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project1.dbo.NashvilleHousing a
JOIN project1.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
--WHERE a.PropertyAddress is null


--Breaking out address into Individual Columns (Address, City, State)

SELECT *
FROM project1.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM project1.dbo.NashvilleHousing

ALTER TABLE project1.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE project1.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE project1.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE project1.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM project1.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address
FROM project1.dbo.NashvilleHousing


ALTER TABLE project1.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE project1.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE project1.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE project1.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE project1.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE project1.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change 1 and 0 to YES and NO in 'Sold as Vacant' field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM project1.dbo.NashvilleHousing
GROUP BY SoldAsVacant

ALTER TABLE project1.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant nvarchar(10)

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = '0' THEN 'No'
		 WHEN SoldAsVacant = '1' THEN 'Yes'
		 ELSE SoldAsVacant
	END
FROM project1.dbo.NashvilleHousing

UPDATE project1.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = '0' THEN 'No'
		 WHEN SoldAsVacant = '1' THEN 'Yes'
		 ELSE SoldAsVacant
	END



-- Remove Duplicates

COMMIT;

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) AS row_num
FROM project1.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY ParcelID

ROLLBACK;



-- Delete Unused Columns

SELECT *
FROM project1.dbo.NashvilleHousing

ALTER TABLE project1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict