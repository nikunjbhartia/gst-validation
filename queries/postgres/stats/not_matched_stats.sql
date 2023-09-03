CREATE TABLE not_matched_invoices_stats AS
SELECT
    supplier,
    gstin,
    SUM(COALESCE(tally_gross_total,0)) as tally_invoice_not_matched_total,
    SUM(COALESCE(gst_invoice_value,0)) as gst_invoice_not_matched_total,
    ABS((SUM(COALESCE(tally_gross_total,0)) - SUM(COALESCE(gst_invoice_value,0)))) as tally_diff_gst_value,
    COALESCE(ABS(ROUND(CAST((SUM(COALESCE(tally_gross_total,0)) - SUM(COALESCE(gst_invoice_value,0)))*100/NULLIF(SUM(tally_gross_total),0) AS NUMERIC),1)),100) as ptg_diff
FROM invoices_not_matched
GROUP BY supplier, gstin
ORDER BY tally_diff_gst_value DESC, tally_invoice_not_matched_total DESC;