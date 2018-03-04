-- Ranking within the entire result
SELECT cvd.name, SUM(ifa.extcost), RANK() OVER ( ORDER BY SUM(ifa.extcost) DESC ) as rank
FROM inventory_fact ifa
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
GROUP BY ifa.custvendorkey, cvd.name;


-- Ranking within a partition
SELECT cvd.state, cvd.name, SUM(ifa.extcost), RANK() OVER ( PARTITION BY cvd.state ORDER BY SUM(ifa.extcost) DESC ) as rank
FROM inventory_fact ifa
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
GROUP BY ifa.custvendorkey, cvd.name, cvd.state
ORDER BY cvd.state;


-- Ranking and dense ranking within the entire result
SELECT
  cvd.name,
  COUNT(*),
  RANK() OVER ( ORDER BY COUNT(*) DESC ) as normal_rank,
  DENSE_RANK() OVER ( ORDER BY COUNT(*) DESC ) as dense_rank
FROM inventory_fact ifa
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
GROUP BY ifa.custvendorkey, cvd.name;


-- Cumulative extended costs for the entire result
SELECT cvd.zip, dd.calyear, dd.calmonth, SUM(ifa.extcost),
  SUM(SUM(ifa.extcost)) OVER ( ORDER BY cvd.zip, dd.calyear, dd.calmonth ROWS UNBOUNDED PRECEDING ) AS CumExtCost
FROM inventory_fact ifa
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
WHERE ifa.transtypekey = 5
GROUP BY cvd.zip, dd.calyear, dd.calmonth
ORDER BY cvd.zip, dd.calyear, dd.calmonth;


-- Cumulative extended costs for a partition
SELECT
  cvd.zip,
  dd.calyear,
  dd.calmonth,
  SUM(ifa.extcost),
  SUM(SUM(ifa.extcost)) OVER ( PARTITION BY cvd.zip, dd.calyear ORDER BY cvd.zip, dd.calyear, dd.calmonth ROWS UNBOUNDED PRECEDING ) AS CumExtCost
FROM inventory_fact ifa
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
WHERE ifa.transtypekey = 5
GROUP BY cvd.zip, dd.calyear, dd.calmonth
ORDER BY cvd.zip, dd.calyear, dd.calmonth;