/*

Cleaning Data in SQL Queries using MySQL Workbench

*/ 


select * 
from housing;


---------------------------------------------------------------------------------------------------- 


-- Populate Property Address Data 


select * 
from housing
where property_address = '';

select * 
from housing
order by Parcel_ID;

-- replace empty string with null value
set sql_safe_updates = 0;
update housing 
set property_address = case property_address when '' then null else property_address end;

-- join table to itself to find missing property address
select A.parcel_id, A.property_address, B.parcel_id, B.property_address, coalesce(A.property_address, B.property_address)
from housing A 
join housing B 
on A.parcel_id = B.parcel_id 
AND A.uniqueid <> B.uniqueid
where A.property_address is null;

update housing A join housing B 
on A.parcel_id = B.parcel_id AND A.uniqueid <> B.uniqueid
set A.property_address = coalesce(A.property_address, B.property_address)
where A.property_address is null;


----------------------------------------------------------------------------------------------------


-- Breaking Out Address Into Individual Columns (address, city, state)


select property_address 
from housing;


select 
substring(property_address, 1, locate(',', property_address)-1) as address,
substring(property_address, locate(',',property_address)+1, char_length(trim(property_address))) as address
from housing;

alter table housing
add property_split_address varchar(255);

update housing
set property_split_address = substring(property_address, 1, locate(',', property_address)-1);

alter table housing 
add property_split_city varchar(255);

update housing 
set property_split_city = substring(property_address, locate(',',property_address)+1, char_length(trim(property_address)));

select * 
from housing;





select Owner_Address
from housing;


select substring_index(owner_address, ',' , 1),
substring_index(substring_index(owner_address, ',' , 2), ',' , -1),
substring_index(owner_address, ',' , -1) 
from housing;

alter table housing 
add owner_split_address varchar(255);

update housing
set owner_split_address = substring_index(owner_address, ',' , 1);

alter table housing 
add owner_split_city varchar(255);

update housing 
set owner_split_city = substring_index(substring_index(owner_address, ',' , 2), ',' , -1);

alter table housing 
add owner_split_state varchar(255);

update housing
set owner_split_state = substring_index(owner_address, ',' , -1);

select * 
from housing;





----------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in column "Sold_As_Vacant" 

select distinct Sold_As_Vacant, count(Sold_As_Vacant) 
from housing
group by Sold_As_Vacant
order by 2 asc;
 
select Sold_As_Vacant, 
case when Sold_As_Vacant = 'Y' then 'Yes'
     when Sold_As_Vacant = 'N' then 'No'
     else Sold_As_Vacant
     end	
from housing;

update housing 
set Sold_As_Vacant = case when Sold_As_Vacant = 'Y' then 'Yes'
     when Sold_As_Vacant = 'N' then 'No'
     else Sold_As_Vacant
     end;





----------------------------------------------------------------------------------------------------


-- Remove Duplicates


with RowNumCTE as 
(
select *, 
	row_number() over (partition by parcel_id, property_address, sale_price, sale_date, legal_reference order by uniqueid) as row_num
from housing
)
delete H
from Housing H inner join RowNumCTE R on H.uniqueid = R.uniqueid
where row_num > 1;

select * 
from housing;





----------------------------------------------------------------------------------------------------


-- Delete Unused Columns

alter table housing
drop column Owner_Address, 
drop column tax_district, 
drop column property_address;



