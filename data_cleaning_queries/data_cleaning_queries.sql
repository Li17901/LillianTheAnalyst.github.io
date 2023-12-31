/*
 
 Cleaning Data in SQL Queries
 
 */
select
	*
from
	`Portfolio-C`.nashville_housing_data_for_data_cleaning_csv nhdfdcc;

-- Create a new cleaning table
create table `Portfolio-C`.nashville_housing_data_cleaning as
select
	*
from
	`Portfolio-C`.nashville_housing_data_for_data_cleaning_csv nhdfdcc;

-- ------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
select
	STR_TO_DATE(sale_date, '%M %d, %Y')
from
	`Portfolio-C`.nashville_housing_data_cleaning;

alter table
	`Portfolio-C`.nashville_housing_data_cleaning
add
	column sale_date_new date null;

update
	`Portfolio-C`.nashville_housing_data_cleaning
set
	sale_date_new = STR_TO_DATE(sale_date, '%M %d, %Y');

-- ------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
Select
	*
From
	`Portfolio-C`.nashville_housing_data_cleaning -- where property_address is null
order by
	parcel_id;

select
	*
from
	`Portfolio-C`.nashville_housing_data_cleaning
where
	LENGTH(property_address) = 0;

select
	a.unique_id,
	b.unique_id,
	a.parcel_id,
	a.property_address,
	b.parcel_id,
	b.property_address,
	if(
		length(a.property_address) = 0,
		b.property_address,
		a.property_address
	)
from
	`Portfolio-C`.nashville_housing_data_cleaning a
	join `Portfolio-C`.nashville_housing_data_cleaning b on a.parcel_id = b.parcel_id
	and a.unique_id != b.unique_id;

update
	`Portfolio-C`.nashville_housing_data_cleaning a
	join `Portfolio-C`.nashville_housing_data_cleaning b on a.parcel_id = b.parcel_id
	and a.unique_id != b.unique_id
set
	a.property_address = if(
		length(a.property_address) = 0,
		b.property_address,
		a.property_address
	)
where
	length(a.property_address) = 0;

select
	a.unique_id,
	b.unique_id,
	a.parcel_id,
	a.property_address,
	b.parcel_id,
	b.property_address,
	if(
		length(a.property_address) = 0,
		b.property_address,
		a.property_address
	)
from
	`Portfolio-C`.nashville_housing_data_cleaning a
	join `Portfolio-C`.nashville_housing_data_cleaning b on a.parcel_id = b.parcel_id
	and a.unique_id != b.unique_id
where
	length(a.property_address) = 0;

-- ------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
select
	property_address
from
	`portfolio-c`.nashville_housing_data_cleaning;

-- where property_address is null
-- order by parcel_id ;
select
	substr(
		property_address,
		1,
		locate(',', property_address) -1
	) as address,
	substr(
		property_address,
		locate(',', property_address) + 1,
		length (property_address)
	) as address
from
	`portfolio-c`.nashville_housing_data_cleaning;

alter table
	`portfolio-c`.nashville_housing_data_cleaning
add
	column property_split_address varchar(255)
after
	sale_date_new;

select
	substr(
		property_address,
		1,
		locate(',', property_address) -1
	)
from
	`portfolio-c`.nashville_housing_data_cleaning;

update
	`portfolio-c`.nashville_housing_data_cleaning
set
	property_split_address = substr(
		property_address,
		1,
		locate(',', property_address) -1
	);

alter table
	`portfolio-c`.nashville_housing_data_cleaning
add
	column property_split_city varchar(255)
after
	property_split_address;

select
	substr(
		property_address,
		locate(',', property_address) + 1,
		length (property_address)
	)
from
	`portfolio-c`.nashville_housing_data_cleaning;

update
	`portfolio-c`.nashville_housing_data_cleaning
set
	property_split_city = substr(
		property_address,
		locate(',', property_address) + 1,
		length (property_address)
	);

select
	*
from
	`portfolio-c`.nashville_housing_data_cleaning;

select
	owner_address
from
	`portfolio-c`.nashville_housing_data_cleaning;

select
	substring_index(replace(owner_address, ',', '.'), '.', 1),
	substring_index(
		substring_index(replace(owner_address, ',', '.'), '.', -2),
		'.',
		1
	),
	substring_index(replace(owner_address, ',', '.'), '.', -1)
from
	`portfolio-c`.nashville_housing_data_cleaning;

alter table
	`portfolio-c`.nashville_housing_data_cleaning
add
	column owner_split_address varchar(255)
after
	property_split_address;

select
	substring_index(replace(owner_address, ',', '.'), '.', 1)
from
	`portfolio-c`.nashville_housing_data_cleaning;

update
	`portfolio-c`.nashville_housing_data_cleaning
set
	owner_split_address = substring_index(replace(owner_address, ',', '.'), '.', 1);

alter table
	`portfolio-c`.nashville_housing_data_cleaning
add
	column owner_split_city varchar(255)
after
	owner_split_address;

select
	substring_index(
		substring_index(replace(owner_address, ',', '.'), '.', -2),
		'.',
		1
	)
from
	`portfolio-c`.nashville_housing_data_cleaning;

update
	`portfolio-c`.nashville_housing_data_cleaning
set
	owner_split_city = substring_index(
		substring_index(replace(owner_address, ',', '.'), '.', -2),
		'.',
		1
	);

alter table
	`portfolio-c`.nashville_housing_data_cleaning
add
	column owner_split_state varchar(255)
after
	owner_split_city;

select
	substring_index(replace(owner_address, ',', '.'), '.', -1)
from
	`portfolio-c`.nashville_housing_data_cleaning;

update
	`portfolio-c`.nashville_housing_data_cleaning
set
	owner_split_state = substring_index(replace(owner_address, ',', '.'), '.', -1);

select
	*
from
	`portfolio-c`.nashville_housing_data_cleaning;

-- ------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
select
	distinct (sold_asvacant),
	count(sold_asvacant)
from
	`portfolio-c`.nashville_housing_data_cleaning
group by
	sold_asvacant
order by
	2;

select
	sold_asvacant,
	case
		when sold_asvacant = 'Y' then 'Yes'
		when sold_asvacant = 'N' then 'No'
		else sold_asvacant
	end
from
	`portfolio-c`.nashville_housing_data_cleaning;

update
	`portfolio-c`.nashville_housing_data_cleaning
set
	sold_asvacant =case
		when sold_asvacant = 'Y' then 'Yes'
		when sold_asvacant = 'N' then 'No'
		else sold_asvacant
	end;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
create table nashville_housing_data_cleaning_no_duplicates
select
	*
from
	(
		select
			*,
			row_number() over (
				partition by parcel_id,
				property_address,
				sale_price,
				sale_date,
				legal_reference
				order by
					unique_id
			) as row_num
		from
			`portfolio-c`.nashville_housing_data_cleaning
		order by
			unique_id
	) t1
where
	row_num = 1
order by
	property_address;

-- -------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
Select
	*
from
	`portfolio-c`.nashville_housing_data_cleaning_no_duplicates;

ALTER TABLE
	`portfolio-c`.nashville_housing_data_cleaning_no_duplicates DROP COLUMN owner_address,
	DROP COLUMN tax_district,
	DROP COLUMN property_address,
	DROP COLUMN sale_date;