SELECT
  branchess.branchcode AS LIBRARY,
  branchess.lib AS LOCATION,
  icounts.Count_itemnumber AS CURRENT_ITEM_COUNT,
  IFNULL(statcounts.COUNT, 0) AS CIRCS_IN_TIMEFRAME,
  CONCAT('<span class="turnover_count">', IFNULL(ROUND((statcounts.COUNT / icounts.Count_itemnumber), 2), '---'), '</span>') AS TURNOVER
FROM
  (SELECT branches.branchcode, biblocs.authorised_value, biblocs.lib
   FROM branches,
     (SELECT authorised_values.category, authorised_values.authorised_value, authorised_values.lib
      FROM authorised_values
      WHERE authorised_values.category = 'LOC'
     ) biblocs
  ) branchess
  LEFT JOIN
  (SELECT
     items.homebranch, items.permanent_location, COUNT(items.itemnumber) AS Count_itemnumber
   FROM
     items
   GROUP BY
     items.homebranch, items.permanent_location
   ) icounts ON icounts.homebranch = branchess.branchcode AND
      icounts.permanent_location = branchess.authorised_value
  LEFT JOIN
  (SELECT
     statistics.branch, statistics.location AS LOCATION, COUNT(*) AS COUNT
   FROM
     statistics
   WHERE (statistics.type = 'issue' OR statistics.type = 'renew' OR statistics.type = 'localuse')
     AND (statistics.datetime BETWEEN <<Circulation stats between|date>> AND <<and|date>>)
   GROUP BY statistics.branch, statistics.location
  ) statcounts ON statcounts.branch = branchess.branchcode AND
      statcounts.LOCATION = branchess.authorised_value
WHERE
  branchess.branchcode LIKE <<Choose Library|branches:all>>
GROUP BY
  branchess.branchcode,
  branchess.lib,
  icounts.Count_itemnumber,
  statcounts.COUNT
HAVING CURRENT_ITEM_COUNT IS NOT NULL
LIMIT 1000
