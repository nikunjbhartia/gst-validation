# gst-validation
This validated GSTR2A csv files with Tally exported data 

## Usage:
1) Store all the GSTR2A csv files in the folder : "exports/portal/*.csv"  
2) Store all the tally Excel export files in the folder: "exports/tally/*.csv"  
3) Install postgres, preferably local. Remote will also do
4) Update the gst.py file with postgres connection details 
5) Execute the script: python3 gst.py

## Output 
- Output is stored as an excel file in the folder "output" in the format "validation_result_YYYYMMDD_HHmmss.xlsx"   
 
