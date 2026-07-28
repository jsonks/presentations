SELECT
     CASE
       WHEN items.itemcallnumber BETWEEN 'J000' AND 'J099.99999999' THEN 'J000-J099'
       WHEN items.itemcallnumber BETWEEN 'J100' AND 'J199.99999999' THEN 'J100-J199'
       WHEN items.itemcallnumber BETWEEN 'J200' AND 'J299.99999999' THEN 'J200-J299'
       WHEN items.itemcallnumber BETWEEN 'J300' AND 'J399.99999999' THEN 'J300-J399'
       WHEN items.itemcallnumber BETWEEN 'J400' AND 'J499.99999999' THEN 'J400-J499'
       WHEN items.itemcallnumber BETWEEN 'J500' AND 'J599.99999999' THEN 'J500-J599'
       WHEN items.itemcallnumber BETWEEN 'J600' AND 'J699.99999999' THEN 'J600-J699'
       WHEN items.itemcallnumber BETWEEN 'J700' AND 'J799.99999999' THEN 'J700-J799'
       WHEN items.itemcallnumber BETWEEN 'J800' AND 'J899.99999999' THEN 'J800-J899'
       WHEN items.itemcallnumber BETWEEN 'J900' AND 'J999.99999999' THEN 'J900-J999'
     ELSE 'Alternate categorization'
     END
    AS 'DeweyRange',
    COUNT(*) AS 'Count of items',
    AVG(copyrightdate) AS 'Avg Copyright'
FROM
    biblio
    INNER JOIN items USING (biblionumber)
WHERE copyrightdate IS NOT NULL
AND items.permanent_location = '160200JUVNF'
AND items.homebranch LIKE <<Choose Library|branches:all>>
GROUP BY DeweyRange
ORDER BY DeweyRange
