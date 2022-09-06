Select * from Portfolio_project..Netflix
--Standardizing the Date Format
Select DateConverted, CONVERT(date, date_added)
from Portfolio_project..Netflix

update Netflix
SET date_added=CONVERT(Date, date_added)

Alter Table Netflix
ADD DateConverted DATE;

update Netflix
SET DateConverted=CONVERT(Date, date_added)

---Removing the duplicates
-----
With RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
partition by type,
			director,
			country,
			duration
			order by 
			show_id) row_num

from Portfolio_project..Netflix
--order by show_id
)
SELECT * 
from RowNumCTE
Where row_num > 1
Order by director

----Delete the unsed column
Select * from Portfolio_project..Netflix
order by type

Alter table Portfolio_project..Netflix
DROP column date_added
