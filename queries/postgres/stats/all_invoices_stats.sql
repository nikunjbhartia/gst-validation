CREATE TABLE all_invoices_stats AS
SELECT
    supplier,
    gstin,
    SUM(COALESCE(tally_gross_total,0)) as all_tally_invoices_total,
    SUM(COALESCE(gst_invoice_value,0)) as all_gst_invoices_total,
    ABS((SUM(COALESCE(tally_gross_total,0)) - SUM(COALESCE(gst_invoice_value,0)))) as tally_diff_gst_value,
    COALESCE(ABS(ROUND(CAST((SUM(COALESCE(tally_gross_total,0)) - SUM(COALESCE(gst_invoice_value,0)))*100/NULLIF(SUM(tally_gross_total),0) AS NUMERIC),1)),100) as ptg_diff
FROM all_invoices
GROUP BY supplier, gstin
ORDER BY COALESCE(SUM(tally_gross_total),SUM(gst_invoice_value)) DESC ;