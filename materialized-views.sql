-- Create Materialized View for 2011 Shipments

CREATE MATERIALIZED VIEW SalesByVendorDateKeyMV2011
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
  ENABLE QUERY REWRITE AS
  SELECT CustVendorKey, dd.DateKey, SUM(ExtCost) AS SumExtCost, SUM(Quantity) AS SumQte, COUNT(*) AS CountTrans
  FROM inventory_fact ifa
    INNER JOIN date_dim dd ON ifa.DateKey = dd.DateKey
  WHERE TransTypeKey = 5
    AND CalYear = 2011
  GROUP BY CustVendorKey, dd.DateKey;



-- Create Materialized View for 2012 Shipments

CREATE MATERIALIZED VIEW SalesByVendorDateKeyMV2012
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
  ENABLE QUERY REWRITE AS
  SELECT CustVendorKey, dd.DateKey, SUM(ExtCost) AS SumExtCost, SUM(Quantity) AS SumQte, COUNT(*) AS CountTrans
  FROM inventory_fact ifa
    INNER JOIN date_dim dd ON ifa.DateKey = dd.DateKey
  WHERE TransTypeKey = 5
    AND CalYear = 2012
  GROUP BY CustVendorKey, dd.DateKey;



-- Rewrite query using Materialized view

SELECT CalMonth, AddrCatCode1, SUM(SumExtCost), SUM(SumQte)
FROM SalesByVendorDateKeyMV2011 sv
  INNER JOIN date_dim dd ON dd.DateKey = sv.DateKey
  INNER JOIN cust_vendor_dim cvd ON sv.CustVendorKey = cvd.CustVendorKey
GROUP BY CUBE(CalMonth, AddrCatCode1);



-- Rewrite query using a UNION of Materialized views

SELECT CalQuarter, Name, Zip, SUM(SumExtCost) AS SumExtCost, SUM(CountTrans) AS CountTrans
FROM (
  SELECT CalQuarter, cvd.Name, cvd.Zip, SumExtCost, CountTrans
  FROM SalesByVendorDateKeyMV2011 sv1
    INNER JOIN date_dim dd ON dd.DateKey = sv1.DateKey
    INNER JOIN cust_vendor_dim cvd ON cvd.CustVendorKey = sv1.CustVendorKey
  UNION
  SELECT CalQuarter, cvd.Name, cvd.Zip, SumExtCost, CountTrans
  FROM SalesByVendorDateKeyMV2012 sv2
    INNER JOIN date_dim dd ON dd.DateKey = sv2.DateKey
    INNER JOIN cust_vendor_dim cvd ON cvd.CustVendorKey = sv2.CustVendorKey
)
GROUP BY CUBE(CalQuarter, Name, Zip);
