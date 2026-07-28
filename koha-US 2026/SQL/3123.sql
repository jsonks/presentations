SELECT CONCAT('<a class="clicked" href=\"/cgi-bin/koha/catalogue/detail.pl?biblionumber=',i.biblionumber,'\" target="_blank">'"view"'</a>') AS "view",
       CONCAT('<a class="clicked" href=\"/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=',b.biblionumber,'\" target="_blank" >',"edit",'</a>') AS "edit",
       b.biblionumber,
       b.title,
       b.copyrightdate,
       SUBSTR(ExtractValue(metadata,'//controlfield[@tag="008"]'),34,1) AS '008litform',
       CASE SUBSTR(ExtractValue(metadata,'//controlfield[@tag="008"]'),34,1)
		WHEN '0' THEN 'Not fiction'
		WHEN '1' THEN 'Fiction'
	   ELSE SUBSTR(ExtractValue(metadata,'//controlfield[@tag="008"]'),34,1) END AS litformdesc,
       i.homebranch,
       i.permanent_location AS loc,
       av.lib AS locdesc,
       i.itemcallnumber, i.itemnumber
FROM biblio b
LEFT JOIN items i ON (b.biblionumber = i.biblionumber)
LEFT JOIN biblio_metadata b2 ON (b.biblionumber=b2.biblionumber)
LEFT JOIN authorised_values av ON (i.permanent_location = av.authorised_value AND av.category = "LOC")
WHERE i.homebranch LIKE <<Choose Library|branches:all>>
     AND i.ccode IN ('AB', 'JB')
     AND i.permanent_location NOT LIKE '%AUTO%'
     AND i.permanent_location NOT LIKE '%DISPLAY%'
     AND i.permanent_location NOT LIKE '%NEW%'
     AND i.permanent_location NOT LIKE '%PARENTING%'
     AND i.permanent_location NOT LIKE '%SPANISH%'
     AND i.permanent_location NOT LIKE '%STORED%'
/*     AND i.permanent_location NOT LIKE '%JUVFICE%' */
     /*AND b.biblionumber IN ('777660', '806282', '806597')*/
GROUP BY i.itemnumber
HAVING (008litform = '0' AND loc NOT LIKE ('%NF%')
    OR 008litform = '1' AND loc NOT LIKE ('%FIC%'))
ORDER BY locdesc ASC, i.itemcallnumber    

