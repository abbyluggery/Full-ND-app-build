@echo off
echo.
echo ==========================================
echo Fix Daily_Routine__c Fields Deployment
echo ==========================================
echo.
echo This script will help deploy the missing 13 wellness fields
echo for the Daily_Routine__c object that are not currently in your org.
echo.
echo Missing fields:
echo - Energy_Level_Morning__c (Number, 0-10)
echo - Energy_Level_Afternoon__c (Number, 0-10)
echo - Energy_Level_Evening__c (Number, 0-10)
echo - Mood__c (Text, 255)
echo - Stress_Level__c (Number, 0-10)
echo - Exercise_Completed__c (Checkbox)
echo - Exercise_Type__c (Text, 255)
echo - Water_Intake__c (Number)
echo - Morning_Routine_Complete__c (Checkbox)
echo - Accomplished_Today__c (Long Text Area)
echo - Challenges__c (Long Text Area)
echo - Gratitude__c (Long Text Area)
echo - Tomorrow_Priorities__c (Long Text Area)
echo.
echo To fix this issue, you have two options:
echo.
echo OPTION 1: Deploy via Salesforce Setup UI (Recommended)
echo 1. Log into your Salesforce org
echo 2. Go to Setup → Object Manager → Daily_Routine__c
echo 3. Click "Fields & Relationships"
echo 4. Click "New" for each missing field
echo 5. Configure each field according to the specifications above
echo.
echo OPTION 2: Deploy using Salesforce CLI
echo 1. Make sure you have the Salesforce CLI installed
echo 2. Run this command from the project root:
echo    sf deploy metadata --source-dir force-app/main/default/objects/Daily_Routine__c
echo.
echo OPTION 3: Force redeployment using destructive changes
echo 1. Create a destructiveChanges.xml file to remove and re-add the object
echo 2. Deploy with destructive changes
echo.
echo Press any key to exit...
pause
