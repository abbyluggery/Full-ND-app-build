// Bulk insert Job Postings via Anonymous Apex
List<Job_Posting__c> jobs = new List<Job_Posting__c>();

jobs.add(new Job_Posting__c(
    Title__c = 'Senior Salesforce Developer',
    Company__c = 'TechForward Inc',
    Location__c = 'Remote',
    Salary__c = '$120,000 - $145,000',
    Status__c = 'Analyzing',
    URL__c = 'https://example.com/jobs/sf-dev-001',
    Description__c = 'Join our remote-first team building innovative Salesforce solutions. We value deep work time, provide clear documentation, and offer flexible schedules. Our interview process is transparent with all questions provided in advance. Accommodations welcomed.',
    Company_Culture__c = 'Remote-first culture with emphasis on async communication and work-life balance',
    Required_Skills__c = 'Apex, Lightning Web Components, REST APIs, Git',
    Preferred_Skills__c = 'JavaScript, Python, DevOps experience',
    Benefits__c = 'Health insurance, 401k match, unlimited PTO, home office stipend, professional development budget',
    Application_Deadline__c = Date.newInstance(2025, 12, 31),
    Job_Type__c = 'Full-Time',
    Remote_Work_Available__c = true,
    Years_Experience_Required__c = 5
));

jobs.add(new Job_Posting__c(
    Title__c = 'Salesforce Administrator',
    Company__c = 'HealthCare Solutions LLC',
    Location__c = 'Hybrid - Boston, MA',
    Salary__c = '$75,000 - $95,000',
    Status__c = 'Saved',
    URL__c = 'https://example.com/jobs/sf-admin-002',
    Description__c = 'Manage our growing Salesforce instance supporting healthcare operations. Collaborative team environment with structured processes and regular training opportunities.',
    Company_Culture__c = 'Professional healthcare environment with standard business hours',
    Required_Skills__c = 'Salesforce Administration, Data Management, Process Builder, Reports & Dashboards',
    Preferred_Skills__c = 'Flow Builder, Health Cloud experience',
    Benefits__c = 'Health insurance, dental, vision, 15 days PTO, 401k',
    Application_Deadline__c = Date.newInstance(2025, 11, 30),
    Job_Type__c = 'Full-Time',
    Remote_Work_Available__c = false,
    Years_Experience_Required__c = 3
));

jobs.add(new Job_Posting__c(
    Title__c = 'Junior Salesforce Developer',
    Company__c = 'StartUp Innovations',
    Location__c = 'Remote',
    Salary__c = '$65,000 - $80,000',
    Status__c = 'Applied',
    URL__c = 'https://example.com/jobs/jr-dev-003',
    Description__c = 'Entry-level position for motivated developer looking to grow. Mentorship program, pair programming, and supportive team environment.',
    Company_Culture__c = 'Fast-paced startup with mentorship focus and collaborative coding practices',
    Required_Skills__c = 'Basic Apex knowledge, HTML/CSS, Willingness to learn',
    Preferred_Skills__c = 'Any programming experience, Git basics',
    Benefits__c = 'Health insurance, equity options, flexible hours, learning budget',
    Application_Deadline__c = Date.newInstance(2025, 11, 15),
    Job_Type__c = 'Full-Time',
    Remote_Work_Available__c = true,
    Years_Experience_Required__c = 1,
    Application_Date__c = Date.newInstance(2025, 10, 28)
));

jobs.add(new Job_Posting__c(
    Title__c = 'Salesforce Business Analyst',
    Company__c = 'Enterprise Corp',
    Location__c = 'On-site - New York, NY',
    Salary__c = '$85,000 - $105,000',
    Status__c = 'Saved',
    URL__c = 'https://example.com/jobs/ba-004',
    Description__c = 'Lead requirements gathering and stakeholder management for enterprise Salesforce implementation. Fast-paced environment with frequent context switching and high meeting volume.',
    Company_Culture__c = 'Traditional corporate environment with open office layout and frequent collaboration',
    Required_Skills__c = 'Business Analysis, Stakeholder Management, Salesforce Platform Knowledge',
    Preferred_Skills__c = 'Agile methodology, Project Management',
    Benefits__c = 'Health insurance, 10 days PTO, 401k match',
    Application_Deadline__c = Date.newInstance(2025, 12, 15),
    Job_Type__c = 'Full-Time',
    Remote_Work_Available__c = false,
    Years_Experience_Required__c = 4
));

jobs.add(new Job_Posting__c(
    Title__c = 'Lead Salesforce Architect',
    Company__c = 'CloudTech Solutions',
    Location__c = 'Remote',
    Salary__c = '$150,000 - $180,000',
    Status__c = 'Saved',
    URL__c = 'https://example.com/jobs/architect-005',
    Description__c = 'Design enterprise-scale Salesforce solutions with focus on technical excellence and mentorship. Autonomous work environment with clear expectations and detailed documentation practices.',
    Company_Culture__c = 'Remote-first with emphasis on documentation, async communication, and deep work blocks',
    Required_Skills__c = 'Salesforce Architecture, Integration Patterns, Security Best Practices, Team Leadership',
    Preferred_Skills__c = 'Multiple Salesforce Clouds, Enterprise Architecture, DevOps',
    Benefits__c = 'Comprehensive health coverage, unlimited PTO, $5000 learning budget, home office setup, equity',
    Application_Deadline__c = Date.newInstance(2026, 1, 31),
    Job_Type__c = 'Full-Time',
    Remote_Work_Available__c = true,
    Years_Experience_Required__c = 8
));

jobs.add(new Job_Posting__c(
    Title__c = 'Salesforce Developer (Contract)',
    Company__c = 'Consulting Partners LLC',
    Location__c = 'Remote',
    Salary__c = '$95/hour',
    Status__c = 'Interview Scheduled',
    URL__c = 'https://example.com/jobs/contract-006',
    Description__c = '6-month contract supporting Financial Services Cloud implementation. Clear deliverables and remote work.',
    Company_Culture__c = 'Contract position with defined scope and minimal meetings',
    Required_Skills__c = 'Apex, Visualforce, Financial Services Cloud, REST APIs',
    Preferred_Skills__c = 'Banking domain knowledge',
    Benefits__c = 'Hourly rate, contract terms negotiable',
    Application_Deadline__c = Date.newInstance(2025, 11, 10),
    Job_Type__c = 'Contract',
    Remote_Work_Available__c = true,
    Years_Experience_Required__c = 5,
    Interview_Date__c = Date.newInstance(2025, 11, 5)
));

jobs.add(new Job_Posting__c(
    Title__c = 'Salesforce QA Engineer',
    Company__c = 'Quality First Tech',
    Location__c = 'Remote',
    Salary__c = '$80,000 - $100,000',
    Status__c = 'Saved',
    URL__c = 'https://example.com/jobs/qa-007',
    Description__c = 'Detail-oriented QA engineer for Salesforce testing. Structured testing processes, comprehensive documentation, and clear acceptance criteria. Quiet work environment with focused testing time.',
    Company_Culture__c = 'Process-driven with emphasis on quality, documentation, and systematic approaches',
    Required_Skills__c = 'Salesforce Testing, Test Case Design, JIRA, Regression Testing',
    Preferred_Skills__c = 'Automation testing, Selenium, Provar',
    Benefits__c = 'Health coverage, 20 days PTO, flexible schedule, WFH stipend',
    Application_Deadline__c = Date.newInstance(2025, 12, 20),
    Job_Type__c = 'Full-Time',
    Remote_Work_Available__c = true,
    Years_Experience_Required__c = 3
));

jobs.add(new Job_Posting__c(
    Title__c = 'Part-Time Salesforce Administrator',
    Company__c = 'Non-Profit Community Services',
    Location__c = 'Hybrid - Seattle, WA',
    Salary__c = '$40/hour (20-25 hrs/week)',
    Status__c = 'Saved',
    URL__c = 'https://example.com/jobs/part-time-008',
    Description__c = 'Part-time admin role supporting non-profit mission. Flexible hours, meaningful work, supportive team.',
    Company_Culture__c = 'Mission-driven non-profit with flexible scheduling and collaborative environment',
    Required_Skills__c = 'Salesforce Administration, NPSP experience helpful',
    Preferred_Skills__c = 'Non-profit background, Volunteer management',
    Benefits__c = 'Prorated benefits, flexible schedule, mission-driven work',
    Application_Deadline__c = Date.newInstance(2025, 11, 30),
    Job_Type__c = 'Part-Time',
    Remote_Work_Available__c = true,
    Years_Experience_Required__c = 2
));

jobs.add(new Job_Posting__c(
    Title__c = 'Salesforce Technical Lead',
    Company__c = 'Fast Growth Startup',
    Location__c = 'On-site - San Francisco, CA',
    Salary__c = '$130,000 - $160,000',
    Status__c = 'Not Interested',
    URL__c = 'https://example.com/jobs/lead-009',
    Description__c = 'Lead fast-paced development team in high-growth startup. Frequent pivots, rapid delivery, open office with high energy. Requires on-site presence 5 days/week.',
    Company_Culture__c = 'High-energy startup with rapid change, frequent interruptions, and collaborative open office',
    Required_Skills__c = 'Salesforce Development, Team Leadership, Agile, Rapid Prototyping',
    Preferred_Skills__c = 'Startup experience, Multi-tasking ability',
    Benefits__c = 'Equity, health insurance, catered meals, 10 days PTO',
    Application_Deadline__c = Date.newInstance(2025, 11, 15),
    Job_Type__c = 'Full-Time',
    Remote_Work_Available__c = false,
    Years_Experience_Required__c = 6
));

jobs.add(new Job_Posting__c(
    Title__c = 'Senior Salesforce Developer',
    Company__c = 'Neurodiversity Tech Initiative',
    Location__c = 'Remote',
    Salary__c = '$115,000 - $135,000',
    Status__c = 'Applied',
    URL__c = 'https://example.com/jobs/ndi-010',
    Description__c = 'Join our neurodiversity-affirming tech team building accessible solutions. We provide written communication options, flexible schedules, sensory-friendly virtual meetings, noise-canceling headphones, and unlimited breaks. Interview questions provided 48 hours in advance. Stimming welcomed.',
    Company_Culture__c = 'Explicitly neurodiversity-affirming workplace with accommodations built into workflow, async-first communication, no cameras required, written agendas for all meetings',
    Required_Skills__c = 'Apex, Lightning Web Components, Accessibility standards, REST APIs',
    Preferred_Skills__c = 'Experience with assistive technologies, WCAG compliance',
    Benefits__c = 'Comprehensive health (including mental health), unlimited PTO, $3000 accommodation budget, home office stipend, professional development, sensory-friendly equipment provided',
    Application_Deadline__c = Date.newInstance(2025, 12, 1),
    Job_Type__c = 'Full-Time',
    Remote_Work_Available__c = true,
    Years_Experience_Required__c = 5,
    Application_Date__c = Date.newInstance(2025, 10, 29)
));

insert jobs;
System.debug('Successfully inserted ' + jobs.size() + ' Job Postings');
