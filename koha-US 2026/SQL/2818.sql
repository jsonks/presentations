SELECT
    items.dateaccessioned,
    items.barcode,
    items.itemcallnumber,
    biblio.author,
    concat(biblio.title, ' ', ExtractValue((
        SELECT metadata 
        FROM biblio_metadata
        WHERE biblio.biblionumber = biblio_metadata.biblionumber),
         '//datafield[@tag="245"]/subfield[@code="b"]')) AS FullTitle,
    biblioitems.isbn,
    biblio.copyrightdate,
    ExtractValue( biblio_metadata.metadata, '//datafield[@tag="650"]/subfield[@code="a"]' ) AS 'lcsh',
    COALESCE(CONCAT('<img src="https://images-na.ssl-images-amazon.com/images/P/',
  IF
  (LEFT(TRIM(biblioitems.isbn), 3) = '978',
    CONCAT(SUBSTR(TRIM(biblioitems.isbn), 4, 9),
    REPLACE(MOD(11 - MOD
        (CONVERT(SUBSTR(TRIM(biblioitems.isbn), 4, 1), UNSIGNED INTEGER)*10 +
         CONVERT(SUBSTR(TRIM(biblioitems.isbn), 5, 1), UNSIGNED INTEGER)*9 +
         CONVERT(SUBSTR(TRIM(biblioitems.isbn), 6, 1), UNSIGNED INTEGER)*8 +
         CONVERT(SUBSTR(TRIM(biblioitems.isbn), 7, 1), UNSIGNED INTEGER)*7 +
         CONVERT(SUBSTR(TRIM(biblioitems.isbn), 8, 1), UNSIGNED INTEGER)*6 +
         CONVERT(SUBSTR(TRIM(biblioitems.isbn), 9, 1), UNSIGNED INTEGER)*5 +
         CONVERT(SUBSTR(TRIM(biblioitems.isbn), 10, 1), UNSIGNED INTEGER)*4 +
         CONVERT(SUBSTR(TRIM(biblioitems.isbn), 11, 1), UNSIGNED INTEGER)*3 +
         CONVERT(SUBSTR(TRIM(biblioitems.isbn), 12, 1), UNSIGNED INTEGER)*2, 11
	  ), 11), '10', 'X')
	),
    LEFT(TRIM(biblioitems.isbn), 10)
  ),
     '.01.MZZZZZZZZZ.jpg">'),'<img src="https://dl.dropboxusercontent.com/s/nkun7xeysbqp4q9/noImageAvailable.png?dl=0">') AS Render  
FROM biblio, items, biblioitems, biblio_metadata
WHERE biblio.biblionumber = items.biblionumber 
     AND biblio.biblionumber = biblio_metadata.biblionumber
     AND biblioitems.biblionumber = biblio.biblionumber
     AND biblio.title NOT LIKE "SHAREit%"
     AND items.dateaccessioned  >= <<Items added on or after (yyyy-mm-dd)|date>>
     AND items.homebranch LIKE <<Choose Library|SLIBS>>
     AND biblio.copyrightdate >= <<Titles published on or after (YYYY), or a % symbol for no limit>>
     AND items.ccode LIKE <<Collection code|ccode>>
GROUP BY FullTitle
ORDER BY items.itemcallnumber, biblio.copyrightdate DESC, items.itemcallnumber
LIMIT 10000
