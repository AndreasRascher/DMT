# DMT - Data Migration Tool #

## Features ##
- Read structured files (CSV or XLSX)
- Map source columns to target columns
- Import validated data
- Update data
- Replace values before import
- Create a migration processing plan
- Backup & Restore all mappings and settings
- Log processing time & validation issues, the log can easy be exported to excel
- retry migrating records with error
- delete data in the target table with filters on the source data and/or filters on the target data
- count lines in source and target tables to check your migration progress

## Limitations (by 12.8.23) ##
- max. fieldcontent size is 250 characters
- max. No. of Columns is 300
- no Blob fields

## Import Workflow (SAAS) ##
1. Open the "DMT Source Files" page and upload your files
2. Assign a "DMT Data Layout" to specify column titles an file properties
3. Create a "DMT Import Configuration" and set the target table
4. Import your data into the generic data buffer
5. Map the fields
    - Run "Init Target Fields" to create a list of all possible target fields
    - Set validation policy
    - Use fixed values if required 
6. Open "DMT Replacement" and up replacements if required for the mapped fields
7. Import Data
8. Set up a "DMT Processing Plan" to manage the order of migrations


## Update Workflow (SAAS) ##
1. Open the "DMT Import Configuration" for the Target Table
2. Run "Init Target Fields" if new target fields have been added
3. Run "Update Fields" and select all fields you need to update

