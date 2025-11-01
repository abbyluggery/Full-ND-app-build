// Update MR-0001 with Resume Content
// Run this AFTER part 1

Master_Resume_Config__c resume = [SELECT Id FROM Master_Resume_Config__c LIMIT 1];

// Short version of resume content
resume.Resume_Content__c =
'ABBY LUGGERY | 561-758-7434 | abbyluggery@gmail.com\n' +
'LinkedIn: linkedin.com/in/abby-luggery-02a4b815a/\n\n' +

'SUMMARY: Salesforce Analyst, 2.5+ years Admin experience, 5+ years data analytics\n\n' +

'EXPERIENCE:\n\n' +

'Macquarie | Data Operations Analyst | Oct 2022-Mar 2025\n' +
'• Managed 1000+ records, 99% data integrity\n' +
'• Agentforce implementation (35% efficiency gain)\n' +
'• SOQL/SOSL queries for $50M+ deal flow\n' +
'• Workflow redesign (40% time reduction)\n\n' +

'Freedom Mortgage | Client Underwriting Specialist | Sep 2020-May 2022\n' +
'• 98% data entry accuracy\n' +
'• Excel automation (35% efficiency improvement)\n' +
'• Risk assessment protocols (15% risk reduction)\n\n' +

'Citigroup | AML Analyst II | Mar 2015-Apr 2016\n' +
'• SQL analysis for transaction patterns\n' +
'• Compliance dashboards and SARs\n\n' +

'Firefly Legal | Office Manager | Dec 2008-Apr 2011\n' +
'• Database beta testing (93% error reduction)\n' +
'• $250K annual savings\n\n' +

'EDUCATION: Daytona State College - Programming & Database Management | GPA 3.8\n\n' +

'CERTIFICATIONS:\n' +
'• Agentforce for Service Superbadge (2025)\n' +
'• Prompt Builder Superbadge (2025)\n' +
'• Agent Blazer Champion - 92 Badges\n\n' +

'PROJECTS: AI Job Search Assistant with Claude API, Chrome Extension, REST APIs';

update resume;

System.debug('✅ Part 2 Updated: Resume Content');
