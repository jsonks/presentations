SELECT b.title, b.author, i.itemcallnumber, a.lib, i.barcode, i.dateaccessioned, b.copyrightdate, MAX(o.returndate) AS datelastreturned, (IFNULL(i.issues, 0)+IFNULL(i.renewals, 0)) AS 'Total Circ'
FROM items i
LEFT JOIN old_issues o USING (itemnumber) 
LEFT JOIN biblio b USING (biblionumber)
LEFT JOIN authorised_values a ON (a.authorised_value=i.permanent_location AND a.category= 'LOC')
WHERE i.homebranch LIKE <<Choose Library|branches:all>> AND i.permanent_location RLIKE <<Shelf location grouping|LOC_GROUP>> AND i.onloan IS NULL AND i.itemlost = '0' 
GROUP BY i.itemnumber 
ORDER BY i.itemcallnumber, b.author, b.title ASC

/* This requires a custom Authorised Value category (i.e. LOC_GROUP) that contains a list of values to pattern match separated by pipes (i.e. ADULT|YA) */
