SELECT CONCAT('<a href="/cgi-bin/koha/members/memberentry.pl?op=edit_form&borrowernumber=', borrowernumber, '&step=5">Edit</a>') AS Edit, borrowernumber, cardnumber, CONCAT(firstname, ' ', surname) AS borrower, smsalertnumber, LENGTH(smsalertnumber) as length, borrowers.dateenrolled, borrowers.date_renewed
FROM borrowers
WHERE branchcode = <<Choose Library|branches>>
AND smsalertnumber <> ''
AND LENGTH(smsalertnumber) <> '12'
