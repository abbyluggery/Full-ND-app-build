@echo off
echo.
echo ==========================================
echo Salesforce CSV Bulk Upload Script
echo ==========================================
echo.
echo This script helps you upload the CSV files we created:
echo.
echo 1. Job_Posting__c.csv - 10 job postings
echo 2. Daily_Routine__c.csv - 10 daily routines  
echo 3. Resume_Package__c.csv - 3 resume packages
echo.
echo Before running this script, please ensure:
echo - You have Salesforce Data Loader installed
echo - You have a Salesforce org connection set up
echo - You have the appropriate permissions to create records
echo.
echo Instructions:
echo 1. Open Salesforce Data Loader
echo 2. Log into your Salesforce org
echo 3. For each CSV file:
echo    a. Select "Insert" operation
echo    b. Choose the appropriate object
echo    c. Map fields correctly
echo    d. Execute the import
echo.
echo Files ready for upload:
echo - Job_Posting__c.csv
echo - Daily_Routine__c.csv
echo - Resume_Package__c.csv
echo.
echo Note: The Resume_Package__c.csv has lookup fields that will need to be mapped to actual record IDs
echo after the Job_Posting__c records are created.
echo.
echo Press any key to exit...
pause
