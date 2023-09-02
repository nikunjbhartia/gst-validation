DROP TABLE IF EXISTS all_invoices;

CREATE TABLE all_invoices AS
SELECT
    COALESCE(ti.supplier,gi.supplier) as supplier,
    COALESCE(ti.gstin, gi.gstin) as gstin,
    TO_DATE(gi.date,'DD-MM-YYYY') as gst_date,
    TO_DATE(ti.date,'YYYY-MM-DD') as tally_date,
    gi.number as gst_invoice_number,
    split_part(ti.invoice_number,' / ',1) as tally_invoice_number,
    ROUND(CAST(ti.value as FLOAT)) as tally_invoice_value,
    ROUND(CAST(ti.gross_total AS FLOAT)) as tally_gross_total,
    ROUND(CAST(gi.value AS FLOAT)) as gst_invoice_value
FROM (SELECT
          distinct on (invoice_number) *
      FROM tally_invoices) ti
 FULL OUTER JOIN ( SELECT
                       distinct on (number) g.*,
                       t.supplier as supplier
                   FROM gst_invoices g
                       LEFT JOIN tally_invoices t
                   ON g.gstin = t.gstin) gi
                 ON ti.gstin = gi.gstin
-- AND split_part(ti.invoice_number,' / ',1) = gi.number
AND TO_DATE(gi.date,'DD-MM-YYYY') = TO_DATE(ti.date,'YYYY-MM-DD')
AND ROUND(CAST(ti.gross_total as FLOAT)) = ROUND(CAST(gi.value as FLOAT))
ORDER BY COALESCE(TO_DATE(gi.date,'DD-MM-YYYY'),TO_DATE(ti.date,'YYYY-MM-DD')), COALESCE(ti.gstin, gi.gstin);
