SELECT b.datecreated, IF(ch.biblio_id IS NULL, 'No', 'Yes') AS clubholdplaced, ch.date_created AS 'clubholddate', clubs.name AS 'AuthorClub', GROUP_CONCAT(DISTINCT(clubs.description)) AS 'Continues',
CONCAT('<a href=\"/cgi-bin/koha/reserve/request.pl?biblionumber=',b.biblionumber,'\" target="_blank">',b.title,'</a>') AS "title",
IFNULL(z.EnrolledPatrons, 0) AS "TotalEnrollments",  y.TotalHolds AS 'TotalHolds',
  CONCAT(w.YourEnrollments, Concat(
    '<a href=\"/cgi-bin/koha/reports/guided_reports.pl?reports=2805&phase=Run+this+report&param_name=Choose+Library&sql_params=', 
    w.branchcode,
    '&param_name=Enter+search+term&sql_params=',
    clubs.name,
    '" target="_blank">', 
    ' (view)', 
    '</a>'
  )) AS 'YourEnrollments',
  CONCAT(x.YourHolds, Concat(
    '<a href=\"/cgi-bin/koha/reports/guided_reports.pl?reports=2804&phase=Run+this+report&param_name=Choose+Library&sql_params=', 
    x.branchcode,
    '&param_name=Bibnumber&sql_params=',
    b.biblionumber,
    '" target="_blank">', 
    ' (view)', 
    '</a>'
  )) AS 'YourHolds',
  SUM(i.issues) AS chkouts,
  a.date1, a.date2, 
  bi.pages, bi.size, REGEXP_SUBSTR(bi.size, '[0-9]+') + 0 AS num,
  a.audience AS audience, a.form, a.mtype, b.author, a.lang,
  CONCAT('<a href=\"/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=',b.biblionumber,'\" target="_blank">'"Edit"'</a>') AS "edit"
FROM clubs
LEFT JOIN biblio b ON (TRIM(BOTH '.' FROM(TRIM(',' FROM clubs.name))) = trim(TRIM(BOTH '.' FROM TRIM(BOTH ',' FROM b.author))))
LEFT JOIN biblioitems bi on (b.biblionumber=bi.biblionumber)
LEFT JOIN biblio_metadata bm ON (b.biblionumber=bm.biblionumber)
LEFT JOIN items i ON (b.biblionumber=i.biblionumber)
LEFT JOIN club_holds ch on (ch.biblio_id = b.biblionumber)
LEFT JOIN (
  SELECT name, COUNT(b.borrowernumber) AS EnrolledPatrons
  FROM clubs
  LEFT JOIN club_enrollments ce ON (clubs.id=ce.club_id)
  LEFT JOIN borrowers b ON (ce.borrowernumber=b.borrowernumber)
  WHERE ce.date_canceled IS NULL
  GROUP BY clubs.id) z ON z.name = clubs.name
LEFT JOIN (
  SELECT name, b.branchcode, COUNT(b.borrowernumber) AS YourEnrollments
  FROM clubs
  LEFT JOIN club_enrollments ce ON (clubs.id=ce.club_id)
  LEFT JOIN borrowers b ON (ce.borrowernumber=b.borrowernumber)
  WHERE ce.date_canceled IS NULL
  AND (b.branchcode LIKE @library:= <<Choose Library|branches:all>> COLLATE utf8mb4_unicode_ci)
  GROUP BY clubs.id) w ON w.name = clubs.name 
LEFT JOIN (
  SELECT biblionumber, COUNT(timestamp) AS TotalHolds
  FROM reserves
  GROUP BY biblionumber) y ON y.biblionumber = b.biblionumber
LEFT JOIN (
  SELECT biblionumber, borrowers.branchcode, COUNT(timestamp) AS YourHolds
  FROM reserves
  LEFT JOIN borrowers USING (borrowernumber)
  WHERE borrowers.branchcode LIKE @library
  GROUP BY biblionumber) x ON x.biblionumber = b.biblionumber
LEFT JOIN (
  SELECT biblionumber, Substring(ExtractValue(metadata,'//controlfield[@tag=008]'),23,1) AS audience, Substring(ExtractValue(metadata,'//controlfield[@tag=008]'),8,4) AS date1, Substring(ExtractValue(metadata,'//controlfield[@tag=008]'),12,4) AS date2, Substring(ExtractValue(metadata,'//controlfield[@tag=008]'),24,1) AS form, Substring(ExtractValue(metadata,'//controlfield[@tag=007]'),1,1) AS mtype, Substring(ExtractValue(metadata,'//controlfield[@tag=008]'),35,4) AS lang
  FROM biblio_metadata) a ON a.biblionumber = b.biblionumber
WHERE b.datecreated BETWEEN CURDATE() - INTERVAL 90 DAY AND CURDATE()
 AND b.copyrightdate >= YEAR(CURDATE() - INTERVAL 356 DAY)
 AND b.medium IS NULL
 AND club_template_id IN ('1', '4')
 AND i.homebranch <> 'FRONTENAC'
GROUP BY b.biblionumber
HAVING audience NOT IN ('a', 'b', 'c', 'd', 'j')
    AND mtype NOT IN ('g', 's')
    AND bi.pages NOT LIKE ('%large%')
    AND (date2 = '' OR date2 >= YEAR(CURDATE() - INTERVAL 356 DAY))
    AND (REGEXP_SUBSTR(bi.size, '[0-9]+') + 0 > '19' OR clubs.name LIKE '%Albom%' OR clubs.name LIKE '%Evans%' OR clubs.name LIKE '%Britain%')
/*    AND a.lang LIKE '%eng%' */
ORDER BY b.datecreated DESC
LIMIT 1000
