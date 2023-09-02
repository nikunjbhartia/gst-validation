DROP TABLE IF EXISTS invoices_not_matched;

CREATE TABLE invoices_not_matched AS
SELECT
    COALESCE(ti.gstin, gi.gstin) as gstin,
    gi.number as gst_invoice_number,
    ti.invoice_number as tally_invoice_number,
    CAST(ti.value as FLOAT) as tally_invoice_value,
    CAST(ti.gross_total AS FLOAT) as tally_gross_total,
    CAST(gi.value AS FLOAT) as gst_invoice_value,
    TO_DATE(gi.date,'DD-MM-YYYY') as gst_date,
    TO_DATE(ti.date,'YYYY-MM-DD') as tally_date,
    ti.supplier as tally_supplier
FROM (
         SELECT distinct on (invoice_number) *
         FROM tally_invoices) ti
         FULL OUTER JOIN (
    SELECT distinct on (number) *
    FROM gst_invoices ) gi
ON ti.gstin = gi.gstin
-- AND ti.invoice_number = gi.number
 AND ti.gross_total = gi.value
WHERE ti.invoice_number is NULL or gi.number is NULL
ORDER BY COALESCE(TO_DATE(gi.date,'DD-MM-YYYY'),TO_DATE(ti.date,'YYYY-MM-DD'));

