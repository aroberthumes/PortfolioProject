---------------------------------------------------------------------------------------------------------
--Cleaning data in SQL Queries

Select *
From PortfolioProject.dbo.[Nashville Housing]

---------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.[Nashville Housing]

ALTER TABLE [Nashville Housing]
Add SaleDateConverted Date;

Update [Nashville Housing]
Set SaleDateConverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------
-- Populate Property Address data

Select *
From PortfolioProject.dbo.[Nashville Housing]

---------------------------------------------------------------------------------------------------------
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing] a
JOIN PortfolioProject.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing] a
JOIN PortfolioProject.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.[Nashville Housing]

---------------------------------------------------------------------------------------------------------
--Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))  as Address

From PortfolioProject.dbo.[Nashville Housing]

ALTER TABLE [Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select OwnerAddress
From PortfolioProject.dbo.[Nashville Housing]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
 From PortfolioProject.dbo.[Nashville Housing]


 ALTER TABLE [Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE [Nashville Housing] 
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE [Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

---------------------------------------------------------------------------------------------------------
-- Chnage Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(Soldasvacant)
From PortfolioProject.dbo.[Nashville Housing]
group by SoldAsVacant
order by 2


Select Soldasvacant
, CASE when soldasvacant = 'Y' then 'Yes'
       When Soldasvacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.[Nashville Housing]

Update [Nashville Housing]
SET SoldAsVacant = CASE when soldasvacant = 'Y' then 'Yes'
       When Soldasvacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END

---------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE as (
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

From PortfolioProject.dbo.[Nashville Housing]
--Order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject.dbo.[Nashville Housing] 

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From PortfolioProject.dbo.[Nashville Housing] 

ALTER TABLE PortfolioProject.dbo.[Nashville Housing] 
DROP COLUMN OwnerAddress, Taxdistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.[Nashville Housing] 
DROP COLUMN SaleDate

