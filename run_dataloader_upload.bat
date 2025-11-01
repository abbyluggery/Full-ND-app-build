@echo off
echo.
echo ==========================================
echo Salesforce Data Loader Upload Guide
echo ==========================================
echo.
echo You have Data Loader installed at:
echo C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant
echo.
echo To upload your CSV files:
echo.
echo 1. Run the Data Loader installation (if not already done):
echo    - Double-click install.bat in that directory
echo.
echo 2. After installation:
echo    - Launch Data Loader from Start Menu or Desktop shortcut
echo    - Log into your Salesforce org
echo.
echo 3. For each CSV file, follow these steps:
echo    a. Select "Insert" operation
echo    b. Choose the appropriate object:
echo       - Job_Posting__c.csv -> Job_Posting__c object
echo       - Daily_Routine__c.csv -> Daily_Routine__c object  
echo       - Resume_Package__c.csv -> Resume_Package__c object
echo    c. Browse and select the appropriate CSV file
echo    d. Map fields correctly (Data Loader will guide you)
echo    e. Execute the import
echo.
echo 4. Important considerations:
echo    - Upload Job_Posting__c.csv first (creates the lookup records)
echo    - Then upload Daily_Routine__c.csv
echo    - Finally, upload Resume_Package__c.csv (note: lookup fields may need manual mapping)
echo.
echo Files to upload:
echo    - Job_Posting__c.csv
echo    - Daily_Routine__c.csv
echo    - Resume_Package__c.csv
echo.
echo Press any key to exit...
pause
