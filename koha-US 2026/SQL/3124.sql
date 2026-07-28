SELECT CONCAT('<a href=\"/cgi-bin/koha/catalogue/detail.pl?biblionumber=',items.biblionumber,'\" target="_blank">'"View"'</a>') AS "view", al.timestamp, user, borrowers.branchcode, firstname, surname, module, action, object, biblio.title, items.barcode, CASE
  WHEN JSON_EXTRACT(al.diff, '$.D.withdrawn.O') = 0 THEN ' '
  WHEN JSON_EXTRACT(al.diff, '$.D.withdrawn.O') = 1 THEN 'Temporarily unavailable'
  WHEN JSON_EXTRACT(al.diff, '$.D.withdrawn.O') = 2 THEN 'In repair'
  WHEN JSON_EXTRACT(al.diff, '$.D.withdrawn.O') = 3 THEN 'Missing parts'
END AS Withdrawn_OldVal,
CASE
  WHEN JSON_EXTRACT(al.diff, '$.D.withdrawn.N') = 0 THEN ' '
  WHEN JSON_EXTRACT(al.diff, '$.D.withdrawn.N') = 1 THEN 'Temporarily unavailable'
  WHEN JSON_EXTRACT(al.diff, '$.D.withdrawn.N') = 2 THEN 'In repair'
  WHEN JSON_EXTRACT(al.diff, '$.D.withdrawn.N') = 3 THEN 'Missing parts'
END AS Withdrawn_NewVal,
al.diff
FROM action_logs al
LEFT JOIN borrowers ON (al.user = borrowers.borrowernumber)
LEFT JOIN items ON (al.object = items.itemnumber)
LEFT JOIN biblio ON (items.biblionumber = biblio.biblionumber)
WHERE items.barcode = <<Enter barcode>>
  AND module = 'CATALOGUING'
  AND action IN ('MODIFY')
  AND info LIKE 'item%'
ORDER BY al.timestamp
LIMIT 100000
