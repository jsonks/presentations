SELECT barcode, itemcallnumber, biblio.title, a5.lib as shelfloc, onloan AS 'checked out?', a.lib AS 'lost',
     a2.lib AS 'notloan',
     a3.lib AS 'withdrawn',
     a4.lib AS 'damaged',
     IF(MAX(bt.datesent)>COALESCE(MAX(bt.datearrived),0),'Yes','No') as inTransit,
       CASE r.found
           WHEN 'F' THEN 'Found'
           WHEN 'T' THEN 'In Transit'
           WHEN 'W' THEN 'Waiting'
           ELSE r.found
       END AS 'hold status', i.itemnotes
FROM items i
LEFT JOIN biblio USING (biblionumber)
LEFT JOIN authorised_values a ON (a.authorised_value=i.itemlost AND a.category='LOST')
LEFT JOIN authorised_values a2 ON (a2.authorised_value=i.notforloan AND a2.category='NOT_LOAN')
LEFT JOIN authorised_values a3 ON (a3.authorised_value=i.withdrawn AND a3.category='WITHDRAWN')
LEFT JOIN authorised_values a4 ON (a4.authorised_value=i.damaged AND a4.category='DAMAGED')
LEFT JOIN authorised_values a5 ON (a5.authorised_value=i.permanent_location AND a5.category='LOC')
LEFT JOIN branchtransfers bt ON i.itemnumber = bt.itemnumber
LEFT JOIN reserves r ON (i.itemnumber = r.itemnumber AND r.priority < '1')
WHERE homebranch = 'IOLA'
AND barcode <= '34311000816909'
AND permanent_location IN <<Location multiselect (can choose multiple locs)|LOC:in>>
GROUP BY barcode
ORDER BY itemcallnumber
