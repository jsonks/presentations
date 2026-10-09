SELECT authorised_values.lib AS 'Shelf Location',
       'Collection count' as stat,
       COUNT(1) AS COUNT
FROM items
LEFT JOIN authorised_values ON (items.permanent_location=authorised_values.authorised_value AND authorised_values.category = 'LOC')
WHERE homebranch LIKE <<Choose Library|branches:all>>
  AND
    (items.permanent_location = <<Choose a shelf location|LOC>>)
UNION ALL
SELECT COALESCE(a.lib, a2.lib) AS 'Shelf Location',
       'Checkouts + renewals',
       COUNT(*) AS 'Circs'
FROM statistics s
LEFT JOIN items i ON s.itemnumber=i.itemnumber
LEFT JOIN deleteditems di ON s.itemnumber=di.itemnumber
LEFT JOIN authorised_values a ON i.permanent_location=a.authorised_value
LEFT JOIN authorised_values a2 ON di.permanent_location=a2.authorised_value
WHERE (s.datetime BETWEEN <<Between|date>> AND <<and|date>>)
  AND (COALESCE(i.homebranch,di.homebranch) LIKE <<Choose Library|branches:all>>)
  AND COALESCE(i.permanent_location, di.permanent_location) = <<Choose a shelf location|LOC>>
  AND s.type IN ('issue', 'renew')
