SELECT i.homebranch,
SUM(CASE WHEN(b.copyrightdate >= (YEAR(CURDATE())-1) AND (i.dateaccessioned BETWEEN '2025-11-01' AND '2026-11-01')) THEN 1 ELSE 0 END) AS ItemsWithNewCopyright,
SUM(CASE WHEN(i.dateaccessioned BETWEEN '2025-11-01' AND '2026-11-01') THEN 1 ELSE 0 END) AS ItemsAddedThisYear,
COUNT(*) AS TotalItemCount,
CONCAT((((SUM(CASE WHEN(b.copyrightdate >= (YEAR(CURDATE())-1) AND (i.dateaccessioned BETWEEN '2025-11-01' AND '2026-11-01')) THEN 1 ELSE 0 END))/(COUNT(*)))*100), '%') AS "Percent of collection that's newly published",
ROUND((COUNT(*) * 0.0025), 0) AS "Minimum number of items needed for 2025-2026 Cycle"
FROM items i
LEFT JOIN biblio b USING (biblionumber)
WHERE (i.ccode <> 'ILL' AND i.ccode <> 'ROT' OR i.ccode IS NULL)
AND i.homebranch LIKE <<Choose Library|branches:all>>
GROUP BY i.homebranch
LIMIT 5000
