// Part 1: Create Master Resume with Basic Info and Core Fields
// Run this first in Execute Anonymous

Master_Resume_Config__c masterResume = new Master_Resume_Config__c();

// Basic Information (Name is auto-number, will be MR-0001)
masterResume.Is_Active__c = true;
masterResume.Full_Name__c = 'Abby Luggery';
masterResume.Email__c = 'abbyluggery@gmail.com';
masterResume.Phone__c = '561-758-7434';
masterResume.LinkedIn_URL__c = 'linkedin.com/in/abby-luggery-02a4b815a/';
masterResume.Location__c = 'Remote';
masterResume.Portfolio_URL__c = 'salesforce.com/trailblazer/uacz8xcj9muds0f4ot';

// Professional Summary
masterResume.Professional_Summary__c =
'Salesforce Analyst with 2.5+ years of Administrator-level access and 5+ years of data analytics experience. ' +
'Proven track record maintaining data integrity across 1000+ records with 99%+ accuracy while supporting global user bases. ' +
'Demonstrated excellence in user administration, system configuration, data quality management, and process automation. ' +
'Recent Agentforce for Service Superbadge recipient with Agent Blazer Champion status (92 Trailhead badges). ' +
'Extensive experience in SQL, Tableau, and advanced Excel modeling across financial services and business operations.';

// Technical Skills
masterResume.Skills__c =
'Salesforce Administration, Service Cloud, Lightning Experience, Multi-Cloud Administration, ' +
'User Profiles & Permissions, Security Configuration, Flow Builder, Process Automation, ' +
'SOQL/SOSL Queries, Data Loader, Data Quality Management, Validation Rules, ' +
'Custom Objects & Fields, Agentforce Builder, Case Management, ' +
'SQL, Tableau CRM, Advanced Excel, Data Visualization, Jira, Agile Methodology, ' +
'API Integration Support, ETL Processes, Data Migration, Reporting & Dashboards';

// Education
masterResume.Education__c =
'Daytona State College - Programming and Database Management | GPA: 3.8\n' +
'Salesforce Training - Agent Blazer Champion | 92 Trailhead Badges | 2 Superbadges';

// Certifications
masterResume.Certifications__c =
'Agentforce for Service Superbadge (2025)\n' +
'Prompt Builder Templates Superbadge (2025)\n' +
'Agent Blazer Champion - 92 Trailhead Badges';

try {
    insert masterResume;
    System.debug('========================================');
    System.debug('✅ PART 1 SUCCESS! Master Resume Created!');
    System.debug('========================================');
    System.debug('Record ID: ' + masterResume.Id);
    System.debug('Auto-Number Name: ' + masterResume.Name);
    System.debug('');
    System.debug('COPY THIS ID - You will need it for Part 2:');
    System.debug(masterResume.Id);
    System.debug('========================================');
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}
