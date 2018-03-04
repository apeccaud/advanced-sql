-- SUBTOTAL OPERATORS


-- CUBE : generates a complete set of subtotals for collection of columns 
SELECT dd.calmonth, cvd.addrcatcode1, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear = 2011
GROUP BY CUBE(dd.calmonth, cvd.addrcatcode1);


-- CUBE equivalent using GROUPING SETS
SELECT dd.calquarter, cvd.zip, cvd.name, SUM(ifa.extcost), COUNT(*) AS NB_INV_TRANS
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear IN (2011, 2012)
GROUP BY GROUPING SETS(
  (dd.calquarter, cvd.zip, cvd.name),
  (dd.calquarter, cvd.zip),
  (dd.calquarter, cvd.name),
  (cvd.zip, cvd.name),
  (dd.calquarter),
  (cvd.zip),
  (cvd.name),
  ()
);


-- ROLLUP : generates a partial set of subtotals in order of the grouped columns (hierarchical)
SELECT cd.companyname, bpd.bpname, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN branch_plant_dim bpd ON ifa.branchplantkey = bpd.branchplantkey
  INNER JOIN company_dim cd ON bpd.companykey = cd.companykey
WHERE ifa.transtypekey = 2
GROUP BY ROLLUP(cd.companyname, bpd.bpname);


-- ROLLUP equivalent using GROUPING SETS
SELECT ttd.transdescription, cd.companyname, bpd.bpname, SUM(ifa.extcost), COUNT(*)
FROM inventory_fact ifa
  INNER JOIN trans_type_dim ttd ON ifa.transtypekey = ttd.transtypekey
  INNER JOIN branch_plant_dim bpd ON ifa.branchplantkey = bpd.branchplantkey
  INNER JOIN company_dim cd ON bpd.companykey = cd.companykey
GROUP BY GROUPING SETS(
  (ttd.transdescription, cd.companyname, bpd.bpname),
  (ttd.transdescription, cd.companyname),
  (ttd.transdescription),
  ()
);


-- Partial ROLLUP : produces subtotals for a subset of hierarchically related columns
-- Generates totals on <name, calyear, calquarter>, <name, calyear>, <name>
SELECT dd.calyear, dd.calquarter, cvd.name, SUM(ifa.extcost), COUNT(*) AS NB_INV_TRANS
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear IN (2011, 2012)
GROUP BY cvd.name, ROLLUP(dd.calyear, dd.calquarter);


-- CUBE equivalent using UNION
SELECT dd.calmonth, cvd.addrcatcode1, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear = 2011
GROUP BY dd.calmonth, cvd.addrcatcode1
UNION
SELECT dd.calmonth, NULL, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear = 2011
GROUP BY dd.calmonth
UNION
SELECT NULL, cvd.addrcatcode1, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear = 2011
GROUP BY cvd.addrcatcode1
UNION
SELECT NULL, NULL, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear = 2011;


-- ROLLUP equivalent using UNION
SELECT cd.companyname, bpd.bpname, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN branch_plant_dim bpd ON ifa.branchplantkey = bpd.branchplantkey
  INNER JOIN company_dim cd ON bpd.companykey = cd.companykey
WHERE ifa.transtypekey = 2
GROUP BY cd.companyname, bpd.bpname
UNION
SELECT cd.companyname, NULL, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN branch_plant_dim bpd ON ifa.branchplantkey = bpd.branchplantkey
  INNER JOIN company_dim cd ON bpd.companykey = cd.companykey
WHERE ifa.transtypekey = 2
GROUP BY cd.companyname
UNION
SELECT NULL, NULL, SUM(ifa.extcost), SUM(ifa.quantity)
FROM inventory_fact ifa
  INNER JOIN branch_plant_dim bpd ON ifa.branchplantkey = bpd.branchplantkey
  INNER JOIN company_dim cd ON bpd.companykey = cd.companykey
WHERE ifa.transtypekey = 2;


-- Composite columns using CUBE
-- Skips (name, calquarter)
SELECT dd.calyear, dd.calquarter, cvd.name, SUM(ifa.extcost), COUNT(*) AS NB_INV_TRANS
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear IN (2011, 2012)
GROUP BY CUBE(cvd.name, (dd.calyear, dd.calquarter));


-- GROUPING_ID : generates a hierarchical group number for each result row
SELECT dd.calmonth, cvd.addrcatcode1, SUM(ifa.extcost), SUM(ifa.quantity), GROUPING_ID(dd.calmonth, cvd.addrcatcode1) AS Group_level
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear IN (2011, 2012)
GROUP BY CUBE(dd.calmonth, cvd.addrcatcode1)
ORDER BY Group_Level;


-- Nested Rollup operation
-- Generates totals on <calyear, calquarter>, <callyear>, <> and name
SELECT dd.calyear, dd.calquarter, cvd.name, SUM(ifa.extcost), COUNT(*) AS NB_INV_TRANS
FROM inventory_fact ifa
  INNER JOIN date_dim dd ON ifa.datekey = dd.datekey
  INNER JOIN cust_vendor_dim cvd ON ifa.custvendorkey = cvd.custvendorkey
WHERE ifa.transtypekey = 5
  AND dd.calyear IN (2011, 2012)
GROUP BY GROUPING SETS(cvd.name, ROLLUP(dd.calyear, dd.calquarter));