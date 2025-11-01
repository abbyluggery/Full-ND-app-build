// Part 2: Update Master Resume with Work Experience and Projects
// FIRST: Replace 'YOUR_RECORD_ID_HERE' with the ID from Part 1
// Then run this in Execute Anonymous

Id masterResumeId = 'YOUR_RECORD_ID_HERE'; // PASTE THE ID FROM PART 1 HERE

Master_Resume_Config__c masterResume = [SELECT Id FROM Master_Resume_Config__c WHERE Id = :masterResumeId];

// Work Experience (Most Recent Jobs)
masterResume.Work_Experience__c =
'Macquarie | Data Operations Analyst | Oct 2022 – Mar 2025\n' +
'• Managed user profiles, roles, permissions for 1000+ records (99% data integrity)\n' +
'• Contributed to Agentforce implementation (35% efficiency gain)\n' +
'• Created SOQL/SOSL queries supporting $50M+ deal flow\n' +
'• Redesigned validation workflows (40% processing time reduction)\n' +
'• Environment: Salesforce Multi-Cloud, Service Cloud, Agentforce, SOQL, Tableau CRM\n\n' +

'Freedom Mortgage | Client Underwriting Specialist | Sep 2020 – May 2022\n' +
'• Achieved 98% accuracy in high-volume data entry\n' +
'• Built Excel automation tools (35% efficiency improvement)\n' +
'• Implemented validation protocols (15% risk reduction)\n' +
'• Maintained 100% regulatory compliance (TILA, RESPA, TRID)\n\n' +

'Citigroup | AML Analyst Level II | Mar 2015 – Apr 2016\n' +
'• Utilized SQL for transaction pattern analysis\n' +
'• Created compliance dashboards and SARs reports\n' +
'• Environment: SQL, AML Systems, Data Visualization\n\n' +

'Firefly Legal | Office Manager | Dec 2008 – Apr 2011\n' +
'• Led database beta testing (93% error reduction, 57% efficiency gain)\n' +
'• Established KPI tracking for 500+ associates\n' +
'• Delivered $250K annual savings through process analysis';

// Projects
masterResume.Projects__c =
'AI Job Search Assistant | Salesforce + Claude AI\n' +
'• Chrome Extension for job capture from LinkedIn/Indeed\n' +
'• REST API integration with Claude AI\n' +
'• Automated ND scoring for neurodivergent fit\n' +
'• Custom objects: Job_Posting__c, Resume_Package__c\n' +
'• Technologies: Apex, REST APIs, OAuth, Triggers\n\n' +

'Wellness & Energy Management System\n' +
'• Daily_Routine__c object with 14 custom fields\n' +
'• Energy-adaptive scheduling algorithm\n' +
'• Flow Builder automation workflows';

// Key Achievements
masterResume.Key_Achievements__c =
'• 99% data integrity across 1000+ enterprise records\n' +
'• 35% efficiency gains through Agentforce automation\n' +
'• 40% processing time reduction through workflow redesign\n' +
'• $250K annual cost savings through compliance analysis\n' +
'• 93% error reduction through system optimization\n' +
'• Agent Blazer Champion with 92 Trailhead badges\n' +
'• Built production AI-integrated Salesforce application';

try {
    update masterResume;
    System.debug('========================================');
    System.debug('✅ PART 2 SUCCESS! Work Experience & Projects Added!');
    System.debug('========================================');
    System.debug('Your Master Resume is now complete!');
    System.debug('You can generate tailored resumes for any job posting.');
    System.debug('========================================');
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}
