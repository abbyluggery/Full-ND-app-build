// Update MR-0001 with Resume Content - FIXED VERSION
// Run this AFTER part 1

Master_Resume_Config__c resume = [SELECT Id FROM Master_Resume_Config__c LIMIT 1];

// Resume content without newline characters
resume.Resume_Content__c =
'ABBY LUGGERY | 561-758-7434 | abbyluggery@gmail.com | ' +
'LinkedIn: linkedin.com/in/abby-luggery-02a4b815a/ | ' +
'SUMMARY: Salesforce Analyst, 2.5+ years Admin experience, 5+ years data analytics. ' +
'EXPERIENCE: ' +
'Macquarie Data Operations Analyst Oct 2022-Mar 2025: Managed 1000+ records 99% data integrity, Agentforce implementation 35% efficiency gain, SOQL queries supporting $50M+ deal flow, Workflow redesign 40% time reduction. ' +
'Freedom Mortgage Client Underwriting Specialist Sep 2020-May 2022: 98% data entry accuracy, Excel automation 35% efficiency improvement, Risk assessment protocols 15% risk reduction. ' +
'Citigroup AML Analyst II Mar 2015-Apr 2016: SQL analysis for transaction patterns, Compliance dashboards and SARs. ' +
'Firefly Legal Office Manager Dec 2008-Apr 2011: Database beta testing 93% error reduction, $250K annual savings. ' +
'EDUCATION: Daytona State College Programming and Database Management GPA 3.8. ' +
'CERTIFICATIONS: Agentforce for Service Superbadge 2025, Prompt Builder Superbadge 2025, Agent Blazer Champion 92 Badges. ' +
'PROJECTS: AI Job Search Assistant with Claude API, Chrome Extension, REST APIs';

update resume;

System.debug('SUCCESS! Part 2 Updated: Resume Content');
