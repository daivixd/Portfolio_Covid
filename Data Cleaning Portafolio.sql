-- Estandarizando el formato fecha
-- 1 metodo
select CONVERT(DATE,SaleDate) from dbo.Sheet1$
Update dbo.Sheet1$ 
SET SaleDate = CONVERT(DATE,SaleDate)
-- 2 metodo
ALTER TABLE dbo.Sheet1$
ADD SaleDateConverted DATE;
Update dbo.Sheet1$
SET SaleDateConverted = CONVERT(DATE,SaleDate)
select * from dbo.Sheet1$*/

-- Rellenar datos de dirección de propiedad

SELECT PropertyAddress from dbo.Sheet1$
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.Sheet1$ a JOIN dbo.Sheet1$ b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.Sheet1$ a
JOIN dbo.Sheet1$ b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Cambiando dirección a columnas individuales
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From dbo.Sheet1$

ALTER TABLE dbo.Sheet1$
Add PropertySplitAddress Nvarchar(255);

Update dbo.Sheet1$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE dbo.Sheet1$
Add PropertySplitCity Nvarchar(255);

Update dbo.Sheet1$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From dbo.Sheet1$

Select OwnerAddress
From dbo.Sheet1$


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.Sheet1$

ALTER TABLE dbo.Sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update dbo.Sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE dbo.Sheet1$
Add OwnerSplitCity Nvarchar(255);

Update dbo.Sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE dbo.Sheet1$
Add OwnerSplitState Nvarchar(255);

Update dbo.Sheet1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From dbo.Sheet1$

-- Cambiando [Y] [N] A SOLD VACANT
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.Sheet1$
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM dbo.Sheet1$

update dbo.Sheet1$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remover Duplicados

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

From dbo.Sheet1$
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From dbo.Sheet1$



