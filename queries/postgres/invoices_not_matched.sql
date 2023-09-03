
CREATE TABLE invoices_not_matched AS
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
 AND TO_DATE(gi.date,'DD-MM-YYYY') = TO_DATE(ti.date,'YYYY-MM-DD')
 AND ROUND(CAST(ti.gross_total as FLOAT)) = ROUND(CAST(gi.value as FLOAT))
 AND ( ltrim(split_part(ti.invoice_number,' / ',1),'0') = ltrim(gi.number,'0')
     OR ltrim(split_part(split_part(ti.invoice_number,' / ',1), '/', 1),'0') = ltrim(split_part(gi.number,'/', 1),'0')
     OR ltrim(split_part(split_part(ti.invoice_number,' / ',1), '/', -1),'0') = ltrim(split_part(gi.number,'/', -1),'0')
     OR split_part(ti.invoice_number,' / ',1) LIKE '%' || gi.number || '%'
     OR starts_with(split_part(ti.invoice_number,' / ',1), substring(gi.number,'[0-9]+')) )
WHERE (ti.invoice_number is NULL or gi.number is NULL)
  AND (gi.number is null or length(gi.number) < 16)
ORDER BY COALESCE(TO_DATE(gi.date,'DD-MM-YYYY'),TO_DATE(ti.date,'YYYY-MM-DD')), COALESCE(ti.gstin, gi.gstin);
