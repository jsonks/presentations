SELECT b.branchcode, b.surname, b.preferred_name,
CONCAT("<img src='https://staff.seknfind.org/cgi-bin/koha/svc/barcode?type=QRcode&modulesize=3&barcode=", b.preferred_name, " ", b.surname, " - ", b.branchcode, "' />") AS qr_code
FROM patron_lists pl
LEFT JOIN patron_list_patrons plp USING (patron_list_id)
LEFT JOIN borrowers b ON (plp.borrowernumber = b.borrowernumber)
WHERE pl.patron_list_id = <<List ID from the URL>>
ORDER BY b.surname
