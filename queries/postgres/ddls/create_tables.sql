
DROP TABLE IF EXISTS gst_invoices;
DROP TABLE IF EXISTS tally_invoices;
DROP TABLE IF EXISTS all_invoices;
DROP TABLE IF EXISTS invoices_matched;
DROP TABLE IF EXISTS invoices_not_matched;
DROP TABLE IF EXISTS not_matched_invoices_stats;
DROP TABLE IF EXISTS all_invoices_stats;

CREATE TABLE gst_invoices(
    gstin VARCHAR,
    number VARCHAR,
    date VARCHAR,
    value VARCHAR
);

CREATE TABLE tally_invoices(
   date VARCHAR,
   particulars VARCHAR,
   supplier VARCHAR,
   invoice_number VARCHAR,
   gstin VARCHAR,
   value VARCHAR,
   gross_total VARCHAR
);