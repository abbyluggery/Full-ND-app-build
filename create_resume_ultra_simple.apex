// Ultra-simple version - just creates the record with minimal data
// We'll update it with more details later

Master_Resume_Config__c resume = new Master_Resume_Config__c();

// Just the essentials from your resume
resume.Resume_Content__c =
'Abby Luggery | 561-758-7434 | abbyluggery@gmail.com\n' +
'Salesforce Analyst - 2.5+ years Admin experience | 5+ years data analytics\n\n' +
'EXPERIENCE:\n' +
'Macquarie (2022-2025): Managed 1000+ records, 99% data integrity, Agentforce implementation\n' +
'Freedom Mortgage (2020-2022): 98% accuracy, built automation tools\n' +
'Citigroup (2015-2016): SQL analysis, AML compliance\n\n' +
'SKILLS: Salesforce Admin, Service Cloud, SOQL, Data Loader, SQL, Tableau, Excel\n' +
'CERTIFICATIONS: Agent Blazer Champion, 92 Trailhead Badges, 2 Superbadges';

resume.Technical_Skills__c =
'Salesforce, Service Cloud, SOQL, Data Loader, SQL, Tableau CRM, Excel, Agentforce';

resume.Key_Achievements__c =
'99% data integrity | 35% efficiency gains | 40% time reduction | $250K savings';

insert resume;

System.debug('SUCCESS! ID: ' + resume.Id);
