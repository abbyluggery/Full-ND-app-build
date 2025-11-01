// Create Master Resume - Simple Version
// Just paste your resume text into the Resume_Content field

Master_Resume_Config__c masterResume = new Master_Resume_Config__c();

// Technical Skills - All your tech skills from resume
masterResume.Technical_Skills__c =
'Salesforce: Administration, Service Cloud, Lightning Experience, Multi-Cloud, User Profiles & Permissions, ' +
'Security, Flow Builder, Process Automation, SOQL/SOSL, Data Loader, Custom Objects, Validation Rules, ' +
'Agentforce Builder, Case Management, Sandbox Management, Change Sets\n\n' +
'Data & Analytics: SQL, Tableau CRM, Advanced Excel (VBA, Pivot Tables), Data Visualization, ETL, ' +
'Data Migration, Data Quality Management, Performance Analytics\n\n' +
'Tools & Platforms: Jira, Agile Methodology, API Integration, MuleSoft, HTML, CSS, Database Management, ' +
'System Troubleshooting, Reporting & Dashboards';

// Key Achievements - Your quantified wins
masterResume.Key_Achievements__c =
'• Maintained 99% data integrity across 1000+ enterprise Salesforce records supporting global users\n' +
'• Contributed to Agentforce implementation reducing manual inquiry processing by 35%\n' +
'• Redesigned data validation workflows reducing processing time by 40%\n' +
'• Created SOQL/SOSL queries supporting $50M+ deal flow with executive dashboards\n' +
'• Built Excel automation tools improving operational efficiency by 35%\n' +
'• Led database beta testing reducing errors by 93% and improving efficiency by 57%\n' +
'• Delivered $250K annual savings through regulatory compliance analysis\n' +
'• Achieved Agent Blazer Champion status with 92 Trailhead badges and 2 Superbadges\n' +
'• Built production AI-integrated Salesforce application (Job Search Assistant with Claude AI)';

// Resume Content - Your full resume in text format
// This is where Claude will pull from to tailor resumes
masterResume.Resume_Content__c =
'ABBY LUGGERY\n' +
'Phone: 561-758-7434 | Email: abbyluggery@gmail.com\n' +
'LinkedIn: linkedin.com/in/abby-luggery-02a4b815a/\n' +
'Trailblazer: salesforce.com/trailblazer/uacz8xcj9muds0f4ot\n\n' +

'PROFESSIONAL SUMMARY\n' +
'Salesforce Analyst with 2.5+ years Administrator-level access and 5+ years data analytics experience. ' +
'Proven track record maintaining 99%+ data integrity across 1000+ records while supporting global users. ' +
'Demonstrated excellence in user administration, system configuration, data quality management, and process automation. ' +
'Recent Agentforce for Service Superbadge recipient with Agent Blazer Champion status (92 badges). ' +
'Extensive experience in SQL, Tableau, and Advanced Excel across financial services.\n\n' +

'EXPERIENCE\n\n' +

'Macquarie | Data Operations Analyst | Oct 2022 – Mar 2025 | Remote\n' +
'• Managed user profiles, roles, permissions for 1000+ records with 99% data integrity\n' +
'• Contributed to Agentforce implementation reducing manual processing by 35%\n' +
'• Created SOQL/SOSL queries supporting $50M+ deal flow\n' +
'• Redesigned validation workflows reducing processing time by 40%\n' +
'• Supported integration teams with data migration, testing, deployment coordination\n' +
'• Environment: Salesforce Multi-Cloud, Service Cloud, Agentforce, SOQL, Tableau CRM, Jira\n\n' +

'Freedom Mortgage | Client Underwriting Specialist | Sep 2020 – May 2022 | Remote\n' +
'• Achieved 98% accuracy in high-volume data entry operations\n' +
'• Built Excel automation tools improving efficiency by 35%\n' +
'• Implemented validation protocols reducing default risk by 15%\n' +
'• Maintained 100% regulatory compliance (TILA, RESPA, TRID)\n' +
'• Environment: Advanced Excel, Credit Analysis Tools, Compliance Systems\n\n' +

'Citigroup | AML Analyst Level II | Mar 2015 – Apr 2016 | Jacksonville, FL\n' +
'• Utilized SQL for transaction pattern analysis and anomaly detection\n' +
'• Created compliance dashboards and Suspicious Activity Reports (SARs)\n' +
'• Environment: SQL, AML Systems, Data Visualization Platforms\n\n' +

'Firefly Legal | Office Manager | Dec 2008 – Apr 2011 | Hybrid/Remote\n' +
'• Led database beta testing: 93% error reduction, 57% efficiency gain\n' +
'• Established KPI tracking for 500+ associates\n' +
'• Delivered $250K annual savings through process analysis\n\n' +

'EDUCATION\n' +
'Daytona State College - Programming & Database Management | GPA: 3.8\n' +
'Salesforce Training - Agent Blazer Champion | 92 Badges | 2 Superbadges\n\n' +

'CERTIFICATIONS\n' +
'• Agentforce for Service Superbadge (2025)\n' +
'• Prompt Builder Templates Superbadge (2025)\n' +
'• Agent Blazer Champion - 92 Trailhead Badges\n\n' +

'PROJECTS\n' +
'AI Job Search Assistant - Salesforce + Claude AI Integration\n' +
'• Chrome Extension for job capture from LinkedIn/Indeed\n' +
'• REST API integration with automated ND scoring\n' +
'• Custom Apex: ClaudeAPIService, JobPostingAPI, ResumeGenerator\n' +
'• Technologies: Apex, REST APIs, OAuth, Triggers, Flow Builder';

// Cover Letter Template (optional - can update later)
masterResume.Cover_Letter_Template__c =
'Dear Hiring Manager,\n\n' +
'I am writing to express my interest in the [POSITION] role at [COMPANY]. With 2.5+ years of Salesforce ' +
'Administrator experience and 5+ years in data analytics, I am excited about the opportunity to contribute ' +
'to your team.\n\n' +
'[Claude will customize this section based on the job description]\n\n' +
'Thank you for your consideration.\n\n' +
'Best regards,\nAbby Luggery';

try {
    insert masterResume;
    System.debug('========================================');
    System.debug('✅ SUCCESS! Master Resume Created!');
    System.debug('========================================');
    System.debug('Record ID: ' + masterResume.Id);
    System.debug('Record Name: ' + masterResume.Name);
    System.debug('');
    System.debug('Your Master Resume is ready!');
    System.debug('Claude AI will use this to generate tailored resumes.');
    System.debug('========================================');
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Line: ' + e.getLineNumber());
}
