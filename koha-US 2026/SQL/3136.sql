SELECT  biblio.biblionumber, it.itemnumber, i.imagenumber AS imagenum, branches.branchname AS housedbranch,
    CONCAT("<img alt='", biblio.title, "' class='img-thumbnail' src='https://www.seknfind.org/cgi-bin/koha/opac-image.pl?imagenumber=", i.imagenumber, "'>") AS image,
    CONCAT("<h2>", biblio.title, IFNULL(biblio.subtitle, ''), "</h2>", "<p>", ExtractValue(metadata,'//datafield[@tag="300"]/*'), "</p><p class='badge text-bg-primary'>Housed at: ", branches.branchname, "</p>", CASE WHEN it.onloan IS NULL THEN '' ELSE '<br><p class="badge bg-danger"><i class="fa-solid fa-triangle-exclamation"></i> Checked out</p>' END) AS title,
    CONCAT("<div class='vstack gap-2 mx-auto'><a class='btn btn-secondary' href='/cgi-bin/koha/opac-detail.pl?biblionumber=", biblio.biblionumber, "'>View record</a><a class='btn btn-primary'  href='/cgi-bin/koha/opac-reserve.pl?biblionumber=", biblio.biblionumber, "'>Place hold</a></div>") AS actions,
    ExtractValue(metadata,'//datafield[@tag="246"]/subfield[@code>="a"]') AS moretitles,
    ExtractValue(metadata,'//datafield[@tag="300"]/subfield[@code>="a"]') AS description, ExtractValue(metadata,'//datafield[@tag="650"]/subfield[@code>="a"]') AS subjects,
    it.itemcallnumber, biblio.notes, it.itemnotes, CASE WHEN (it.itemnotes LIKE ("%pickup%") OR it.itemnotes LIKE ("%pick up%") OR it.itemnotes LIKE ("%picked up%")) THEN 1 ELSE 0 END AS pickupcheck
FROM biblio
LEFT JOIN biblio_metadata on (biblio.biblionumber=biblio_metadata.biblionumber)
LEFT JOIN items it ON (it.biblionumber=biblio.biblionumber)
LEFT JOIN cover_images i ON (biblio.biblionumber=i.biblionumber)
LEFT JOIN branches ON (it.homebranch = branches.branchcode)
WHERE (
/*Big books */  (it.itemcallnumber LIKE 'PC Kit Big Books%') OR
/*Early lit */ (it.itemcallnumber LIKE 'PC Kit Early Lit%') OR
/*Flannel */ (it.itemcallnumber LIKE 'PC Kit Flannel%') OR
/*Puppet */ (it.itemcallnumber LIKE 'PC Kit Puppet%') OR
/*STEAM */ (it.itemcallnumber LIKE 'PC Kit STEAM%') OR
/*Miscellaneous */ (it.itemcallnumber BETWEEN 'PC Kit 0%' and 'PC Kit 999' OR it.itemcallnumber = 'PC Kit Storyboard') )
GROUP BY biblio.biblionumber
HAVING pickupcheck <> '1'
ORDER BY title
LIMIT 500
