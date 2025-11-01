// INSTRUCTIONS:
// 1. Open Developer Console (Setup > Developer Console)
// 2. Open Execute Anonymous Window (Debug > Open Execute Anonymous Window)
// 3. Paste ALL of this code
// 4. Click Execute
//
// This will create both JobPostingAPI and JobPostingAPITest classes programmatically

// Step 1: Create JobPostingAPI class
String jobPostingAPICode = '@RestResource(urlMapping=\'/jobposting/*\')\n' +
'global with sharing class JobPostingAPI {\n' +
'\n' +
'    @HttpPost\n' +
'    global static JobPostingResponse createJobPosting(JobPostingRequest request) {\n' +
'        JobPostingResponse response = new JobPostingResponse();\n' +
'\n' +
'        try {\n' +
'            // Create the job posting record\n' +
'            Job_Posting__c job = new Job_Posting__c();\n' +
'            job.Title__c = request.title;\n' +
'            job.Company__c = request.company;\n' +
'            job.Location__c = request.location;\n' +
'            job.Description__c = request.description;\n' +
'            job.Apply_URL__c = request.applyUrl;\n' +
'            job.Provider__c = request.provider != null ? request.provider : \'Dice\';\n' +
'            job.ExternalID__c = request.externalId;\n' +
'            job.Status__c = \'Active\';\n' +
'            job.Posted_Date__c = Date.today();\n' +
'\n' +
'            // Parse workplace type from description/title\n' +
'            job.Workplace_Type__c = determineWorkplaceType(request);\n' +
'\n' +
'            // Parse salary if provided\n' +
'            if (String.isNotBlank(request.salaryMin)) {\n' +
'                try {\n' +
'                    job.Salary_Min__c = Decimal.valueOf(request.salaryMin);\n' +
'                } catch (Exception e) {\n' +
'                    System.debug(\'Could not parse salary min: \' + request.salaryMin);\n' +
'                }\n' +
'            }\n' +
'\n' +
'            if (String.isNotBlank(request.salaryMax)) {\n' +
'                try {\n' +
'                    job.Salary_Max__c = Decimal.valueOf(request.salaryMax);\n' +
'                } catch (Exception e) {\n' +
'                    System.debug(\'Could not parse salary max: \' + request.salaryMax);\n' +
'                }\n' +
'            }\n' +
'\n' +
'            if (String.isNotBlank(request.currencyCode)) {\n' +
'                job.Currency__c = request.currencyCode;\n' +
'            } else {\n' +
'                job.Currency__c = \'USD\';\n' +
'            }\n' +
'\n' +
'            if (String.isNotBlank(request.salaryInterval)) {\n' +
'                job.Interval__c = request.salaryInterval;\n' +
'            } else {\n' +
'                job.Interval__c = \'Yearly\';\n' +
'            }\n' +
'\n' +
'            // Insert the job (trigger will fire and analyze with Claude!)\n' +
'            insert job;\n' +
'\n' +
'            response.success = true;\n' +
'            response.jobId = job.Id;\n' +
'            response.message = \'Job posting created successfully! Claude is analyzing it now.\';\n' +
'\n' +
'        } catch (Exception e) {\n' +
'            response.success = false;\n' +
'            response.message = \'Error creating job posting: \' + e.getMessage();\n' +
'            System.debug(LoggingLevel.ERROR, \'JobPostingAPI Error: \' + e.getMessage());\n' +
'            System.debug(LoggingLevel.ERROR, \'Stack Trace: \' + e.getStackTraceString());\n' +
'        }\n' +
'\n' +
'        return response;\n' +
'    }\n' +
'\n' +
'    private static String determineWorkplaceType(JobPostingRequest request) {\n' +
'        String combined = (request.title + \' \' + request.location + \' \' + request.description).toLowerCase();\n' +
'\n' +
'        if (combined.contains(\'remote\') || combined.contains(\'work from home\')) {\n' +
'            return \'Remote\';\n' +
'        } else if (combined.contains(\'hybrid\')) {\n' +
'            return \'Hybrid\';\n' +
'        } else if (combined.contains(\'on-site\') || combined.contains(\'onsite\') || combined.contains(\'office\')) {\n' +
'            return \'On-Site\';\n' +
'        }\n' +
'\n' +
'        return \'Remote\'; // Default to remote for your search\n' +
'    }\n' +
'\n' +
'    // Request wrapper\n' +
'    global class JobPostingRequest {\n' +
'        public String title;\n' +
'        public String company;\n' +
'        public String location;\n' +
'        public String description;\n' +
'        public String applyUrl;\n' +
'        public String provider;\n' +
'        public String externalId;\n' +
'        public String salaryMin;\n' +
'        public String salaryMax;\n' +
'        public String currencyCode;\n' +
'        public String salaryInterval;\n' +
'    }\n' +
'\n' +
'    // Response wrapper\n' +
'    global class JobPostingResponse {\n' +
'        public Boolean success;\n' +
'        public String jobId;\n' +
'        public String message;\n' +
'    }\n' +
'}';

System.debug('ERROR: Cannot create Apex classes via Execute Anonymous.');
System.debug('');
System.debug('SOLUTION: You need to manually create the class in Developer Console:');
System.debug('1. In Developer Console, click File > New > Apex Class');
System.debug('2. Name it: JobPostingAPI');
System.debug('3. Delete all the template code');
System.debug('4. Copy the code from: force-app/main/default/classes/JobPostingAPI.cls');
System.debug('5. Paste into the Developer Console editor');
System.debug('6. Save (Ctrl+S)');
System.debug('');
System.debug('OR use Workbench:');
System.debug('1. Go to https://workbench.developerforce.com/');
System.debug('2. Login to your org');
System.debug('3. Select Migration > Deploy');
System.debug('4. Upload a zip file with the metadata');
