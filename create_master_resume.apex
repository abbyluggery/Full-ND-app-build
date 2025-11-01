// Create Master Resume Configuration
// This stores your "master resume" content that Claude will tailor for each job

Master_Resume_Config__c masterResume = new Master_Resume_Config__c();
masterResume.Name = 'Abby Luggery - Master Resume';
masterResume.Is_Active__c = true;

// Personal Information
masterResume.Full_Name__c = 'Abby Luggery';
masterResume.Email__c = 'abbyluggery@gmail.com';
masterResume.Phone__c = ''; // Add your phone if you want
masterResume.LinkedIn_URL__c = ''; // Add your LinkedIn URL if you have one
masterResume.Location__c = 'Remote'; // Or your location

// Professional Summary
masterResume.Professional_Summary__c =
'Salesforce Administrator and Developer with expertise in Agentforce, AI integration, and workflow automation. ' +
'Experienced in building custom solutions using Apex, Lightning Web Components, and integrating external APIs. ' +
'Strong focus on neurodivergent-friendly workplace practices and accessibility.';

// Skills (comma-separated)
masterResume.Skills__c =
'Salesforce Administration, Salesforce Development, Apex, Lightning Web Components (LWC), ' +
'Agentforce, AI Integration, Claude API, Flow Builder, Process Builder, ' +
'Custom Objects, Triggers, REST API, Named Credentials, Chrome Extensions, ' +
'Data Modeling, Workflow Automation, Report & Dashboard Design';

// Work Experience (formatted as bullet points)
masterResume.Work_Experience__c =
'**Salesforce Projects**\n' +
'- Built AI-powered Job Search Assistant with Claude API integration\n' +
'- Automated job analysis with ND scoring and fit assessment\n' +
'- Created Chrome Extension for one-click job capture from LinkedIn/Indeed\n' +
'- Developed wellness tracking system with energy-adaptive scheduling\n' +
'- Implemented REST API endpoints and OAuth authentication\n' +
'- Designed custom triggers for automated AI analysis\n\n' +

'**Technical Skills**\n' +
'- Apex development with test coverage and best practices\n' +
'- Lightning Web Components and Aura Components\n' +
'- Integration with external APIs (Claude AI, job boards)\n' +
'- Custom metadata types and configuration management\n' +
'- Flow Builder for complex automation\n' +
'- Chrome Extension development for Salesforce integration';

// Education
masterResume.Education__c =
'Salesforce Training - Self-directed learning\n' +
'Focus: Agentforce, AI Integration, Custom Development';

// Certifications (if any)
masterResume.Certifications__c =
'Salesforce Administrator (in progress)\n' +
'Agentforce Specialist';

// Additional sections
masterResume.Projects__c =
'**Job Search AI Assistant**\n' +
'Built comprehensive job search platform with:\n' +
'- Automated AI analysis using Claude API\n' +
'- ND score calculation for neurodivergent fit\n' +
'- Chrome Extension for job capture\n' +
'- Resume generation tailored to each job\n' +
'- Wellness tracking with energy-based scheduling';

try {
    insert masterResume;
    System.debug('✅ SUCCESS! Master Resume created with ID: ' + masterResume.Id);
    System.debug('You can now generate tailored resumes for job postings!');
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}
