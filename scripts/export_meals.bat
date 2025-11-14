@echo off
REM Export Meal records from Salesforce

cd /d "%~dp0\.."

echo Exporting Meal records from Salesforce...
echo.

sf data query --query "SELECT Id, Name FROM Meal__c ORDER BY Name" --target-org abbyluggery179@agentforce.com --result-format csv > data\existing_meals_export.csv

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Success! Meals exported to: data\existing_meals_export.csv
    echo.
    echo Next step: Run the Excel extraction script
    echo   python scripts\extract_recipes_from_excel.py
) else (
    echo.
    echo Error exporting meals. Please check your Salesforce connection.
)

pause
