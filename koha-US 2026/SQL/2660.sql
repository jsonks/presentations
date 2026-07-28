SELECT 
CONCAT('<a href=\"/cgi-bin/koha/catalogue/detail.pl?biblionumber=',items.biblionumber,'\" target="_blank">'"View"'</a>') AS "view",
CONCAT('<a href=\"/cgi-bin/koha/circ/returns.pl?itemnumber=',items.itemnumber,'&canceltransfer=1&dest=ttr\" target="_blank">',"cancel transfer",'</a>') AS "transfer",
 b.datesent, b.datearrived, b.frombranch,b.tobranch,
 items.barcode, biblio.title, biblio.author, items.itemcallnumber, items.itemlost, items.holdingbranch, items.replacementprice, items.homebranch AS 'itemowner', items.booksellerid,
 r.borrowernumber
FROM branchtransfers as b
LEFT JOIN items on (b.itemnumber = items.itemnumber)
LEFT JOIN biblioitems on (biblioitems.biblioitemnumber = items.biblioitemnumber)
LEFT JOIN biblio on (biblio.biblionumber = biblioitems.biblionumber)
LEFT JOIN reserves r on (biblio.biblionumber=r.biblionumber)
WHERE ((b.frombranch LIKE <<Choose Library|SLIBS>>))
AND b.datearrived is NULL
AND items.homebranch <> 'ROTATION'
AND items.barcode=<<barcode>>
HAVING itemowner = <<Choose Library|SLIBS>>
ORDER BY b.datesent, items.itemcallnumber
LIMIT 8000
