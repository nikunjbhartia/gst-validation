
import csv
import openpyxl
import os
import psycopg2
import codecs


# Local
PG_DB = "returns"
PG_HOST = "127.0.0.1"
PG_PORT = 5432
PG_USER = "root"
PG_PWD = "root"

def process_portal_csv(filepath):
  print(f"Processing file: {filepath}")
  with open(filepath, mode ='r') as file:
    # reading the CSV file
    csvFile = csv.reader(file)
    values = []

    # skipping first 3 lines: 2 lines + 3rd header line
    for i in range(3): next(csvFile)

    # displaying the contents of the CSV file
    for lines in csvFile:
      if len(lines) != 0:
        values.append(f"('{lines[0].strip()}','{lines[1].strip()}','{lines[3].strip()}','{lines[4].strip()}')")

    if len(values) !=0:
      return f"INSERT INTO gst_invoices(gstin,number,date,value) VALUES {','.join(values)}"

    return None


def process_tally_excel(filepath):
  print(f"Processing file: {filepath}")
  dataframe = openpyxl.load_workbook(filepath)

  # Define variable to read sheet
  xlsheet = dataframe.active

  headers = ["date,particulars,supplier,invoice_number,gstin,value,gross_total"]
  values = []
  # Iterate the loop to read the cell values
  for row in range(8, xlsheet.max_row):
    value = []
    for col in range(1,8):
      value.append(f"'{str(xlsheet.cell(row=row, column=col).value).strip()}'")
    values.append(f"({','.join(value)})")

  if len(values) !=0:
   return f"INSERT INTO tally_invoices(date,particulars,supplier,invoice_number,gstin,value,gross_total) VALUES {','.join(values)}"

  return None

def create_tally_table_ddls():
  return [
      "DROP TABLE IF EXISTS tally_invoices;",
      """
      CREATE TABLE tally_invoices(
        date VARCHAR,
        particulars VARCHAR,
        supplier VARCHAR,
        invoice_number VARCHAR,
        gstin VARCHAR,
        value VARCHAR,
        gross_total VARCHAR
      );
      """
  ]

def create_invoices_table_ddls():
  return [
      "DROP TABLE IF EXISTS gst_invoices;",
      """
      CREATE TABLE gst_invoices(
        gstin VARCHAR,
        number VARCHAR,
        date VARCHAR,
        value VARCHAR
      );
      """
  ]

def read_sql_file(file):
  with codecs.open(file, mode='r', encoding='utf-8', buffering=-1) as sql_file:
    return sql_file.read()

def process_directory_files(type,directory):
  # iterate over files in
  # that directory
  sqls = []

  for filename in os.listdir(directory):
    file = os.path.join(directory, filename)
    # checking if it is a file
    if os.path.isfile(file) and not filename.startswith("~"):
      if type == "PORTAL" and filename.endswith(".csv") :
        sqls.append(process_portal_csv(file))
      elif type == "TALLY" and filename.endswith(".xlsx"):
        sqls.append(process_tally_excel(file))
      elif type == "VALIDATION" and filename.endswith(".sql"):
        sqls.append(read_sql_file(file))

  return sqls

def execute_postgres_sqls(list_of_sqls):
  try:
    conn = psycopg2.connect(database=PG_DB, user=PG_USER, password=PG_PWD, host=PG_HOST, port=PG_PORT)
    # conn = jaydebeapi.connect("org.postgresql.Driver",
    #                         "jdbc:postgresql://127.0.0.1:5432/returns",
    #                           ["root", "root"],
    #                         "postgresql-42.6.0.jar",)
    # print("Database opened successfully")
    #  The except block lets you handle the error.

    #Creating a cursor object using the cursor() method
    cursor = conn.cursor()
    data = []

    for sql in list_of_sqls:
      print(f"Executing SQL: \n{sql}")
      cursor.execute(sql)
      conn.commit()
      if sql.startswith("SELECT"):
        data.append(cursor.fetchall())

    return data

  except Exception as error:
    print(error)

  finally:
    if (conn):
      cursor.close()
      conn.close()
      print("PostgreSQL connection is closed")

def store_result_in_excel(filename,data,title):
  if os.path.isfile(filename):
    wBook = openpyxl.load_workbook(filename)
    try:
      sheet = wBook[title]
    except Exception as error:
      sheet = wBook.create_sheet(title)
  else:
    wBook = openpyxl.Workbook()
    sheet = wBook.create_sheet(title)

  sheet.append(["tally_supplier","gstin","gst_date","tally_date", "gst_invoice_number","tally_invoice_number","tally_invoice_value","tally_gross_total","gst_invoice_value"])
  for row in data[0]:
    sheet.append(row)

  wBook.save(filename)

if __name__ == "__main__":
  print('Create a database named "returns" if not present')

  list_of_sqls = \
    create_tally_table_ddls() + \
    create_invoices_table_ddls() + \
    process_directory_files("PORTAL",f"exports{os.sep}portal" ) + \
    process_directory_files("TALLY",f"exports{os.sep}tally" ) + \
    process_directory_files("VALIDATION",f"queries{os.sep}postgres" )

  print(list_of_sqls)

  data = execute_postgres_sqls(list_of_sqls)
  print(data)

  print("Fetching all invoices records")
  data = execute_postgres_sqls(["SELECT * FROM all_invoices"])
  print(data)
  store_result_in_excel("all_invoices.xlsx",data,"All Invoices")

  print("Fetching all Matched records")
  data = execute_postgres_sqls(["SELECT * FROM invoices_matched"])
  print(data)
  store_result_in_excel("all_invoices.xlsx",data,"Matched Invoices")

  print("Fetching all Non Matched records")
  data = execute_postgres_sqls(["SELECT * FROM invoices_not_matched"])
  print(data)
  store_result_in_excel("all_invoices.xlsx",data,"Not Matched Invoices")


