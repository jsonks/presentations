SELECT
DATE(ao.created_on) AS Date,
cr.name AS Register,
COALESCE(t.description, GROUP_CONCAT(DISTINCT(d.description), '<br/>- <a target="_blank" href="/cgi-bin/koha/members/boraccount.pl?borrowernumber=', d.borrowernumber, '">Patron link (', d.borrowernumber, ') </a>' SEPARATOR '<br/>')) AS 'Items sold', 
GROUP_CONCAT(DISTINCT( CASE
   WHEN c.credit_type_code = "PURCHASE" THEN "Point of sale"
   WHEN c.credit_type_code = "PAYMENT" THEN "Account-level payment"
   WHEN c.credit_type_code = "LOST_FOUND" THEN "Refunded lost charge"
   ELSE LOWER(c.credit_type_code)
 END) SEPARATOR '<br>') AS "Transaction type(s)",
 FORMAT(SUM(IF(c.payment_type = 'CASH', ao.amount * -1, 0)),2,'en_US') AS "Cash",
 FORMAT(SUM(IF(c.payment_type = 'CHECK', ao.amount * -1, 0)),2,'en_US') AS "Check",
 FORMAT(SUM(IF(c.payment_type = 'CREDIT', ao.amount * -1, 0)),2,'en_US') AS "Credit Card",
 FORMAT(SUM(IF(c.payment_type IN ('CASH', 'CHECK', 'CREDIT'), ao.amount * -1, 0)),2,'en_US') AS Total
FROM account_offsets ao
LEFT JOIN accountlines d ON (ao.debit_id=d.accountlines_id)
LEFT JOIN accountlines c ON (ao.credit_id=c.accountlines_id)
LEFT JOIN account_debit_types t ON (d.debit_type_code = t.code)
LEFT JOIN cash_registers cr ON (c.register_id = cr.id)
WHERE DATE(ao.created_on) = <<Transactions for|date>>
  AND COALESCE(d.branchcode, c.branchcode) = <<Choose Library|branches>>
  AND ao.type = 'APPLY'
GROUP BY d.debit_type_code
UNION ALL
SELECT
"",
"",
"",
 CONCAT('<span class="fw-bold">', "TOTALS:", '</span>'),
 CONCAT('<span class="fw-bold">',  FORMAT(SUM(IF(c.payment_type = 'CASH', ao.amount * -1, 0)),2,'en_US'), '</span>') AS "Cash",
 CONCAT('<span class="fw-bold">', FORMAT(SUM(IF(c.payment_type = 'CHECK', ao.amount * -1, 0)),2,'en_US'), '</span>') AS "Check",
 CONCAT('<span class="fw-bold">', FORMAT(SUM(IF(c.payment_type = 'CREDIT', ao.amount * -1, 0)),2,'en_US'), '</span>') AS "Credit Card",
 CONCAT('<span class="fw-bold">', FORMAT(SUM(IF(c.payment_type IN ('CASH', 'CHECK', 'CREDIT'), ao.amount * -1, 0)),2,'en_US'), '</span>') AS Total
FROM account_offsets ao
LEFT JOIN accountlines d ON (ao.debit_id=d.accountlines_id)
LEFT JOIN accountlines c ON (ao.credit_id=c.accountlines_id)
LEFT JOIN account_debit_types t ON (d.debit_type_code = t.code)
LEFT JOIN cash_registers cr ON (c.register_id = cr.id)
WHERE DATE(ao.created_on) = <<Transactions for|date>>
  AND COALESCE(d.branchcode, c.branchcode) = <<Choose Library|branches>>
  AND ao.type = 'APPLY'
