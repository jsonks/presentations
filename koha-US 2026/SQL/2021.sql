SELECT i.itemnumber, i.barcode, b.title, i.itemnotes, i.enumchron, i.homebranch, i.notforloan, i.itype, i.replacementprice, i.dateaccessioned
FROM items i
LEFT JOIN biblio b USING (biblionumber)
WHERE i.itemnotes LIKE '%' <<Enter Term>> '%'
AND i.homebranch = <<Choose Library|branches>>
ORDER BY i.dateaccessioned
