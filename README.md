# Salesforce Job Search AI Assistant

An intelligent job search assistant that combines LinkedIn job capture, Claude AI analysis, automated resume generation, and wellness tracking - all in Salesforce.

## Features

### 🤖 AI-Powered Job Analysis
- **Claude AI Integration**: Automatically analyzes job postings for fit, requirements, and red flags
- **Smart Matching**: Compares your skills against job requirements
- **Personalized Insights**: Get tailored advice for each application

### 📝 Automated Resume Generation
- **Dynamic Resume Creation**: Generate custom resumes for each job posting
- **Template System**: Multiple resume templates and configurations
- **Cover Letter Generation**: AI-powered cover letters matching job requirements

### 🔗 Opportunity Integration
- **Auto-Create Opportunities**: When you receive a callback, automatically creates:
  - Opportunity record linked to the job posting
  - Account record for the company
  - Contact record for the recruiter (with LinkedIn profile)
  - Opportunity Contact Role linking recruiter to opportunity
- **Opportunity Path**: Visual tracking of your application pipeline
- **Recruiter Management**: Store and track recruiter contact information

### 🧘 Wellness Tracking
- **Daily Routine Monitoring**: Track morning routine completion, energy levels, mood
- **Energy-Adaptive Scheduling**: Get schedule recommendations based on your energy patterns
- **Flow-Based Check-ins**: Screen flows for daily wellness logging
- **Trend Analysis**: Reports and dashboards for wellness patterns

### 🌐 Chrome Extension Integration
- **LinkedIn Job Capture**: Browser extension to capture jobs while browsing
- **REST API**: Endpoint to receive job data from extension
- **Automatic Processing**: Jobs are analyzed by Claude AI immediately upon capture

## Architecture

### Custom Objects
- **Job_Posting__c**: Stores job listings with AI analysis results
- **Resume_Package__c**: Generated resumes and cover letters
- **Master_Resume__c** / **Master_Resume_Config__c**: Resume templates and configurations
- **Daily_Routine__c**: Wellness tracking data

### Apex Classes
- **JobPostingAPI**: REST endpoint for Chrome extension
- **JobPostingAnalyzer**: Claude AI integration for job analysis
- **ResumeGenerator**: Dynamic resume creation logic
- **ClaudeAPIService**: API client for Claude AI
- **OpportunityCreationHandler**: Auto-creates Opportunities, Accounts, Contacts
- **EnergyAdaptiveScheduler**: Wellness-based scheduling
- **DailyRoutineInvocable**: Flow-callable wellness methods

### Triggers
- **OpportunityCreationTrigger**: Fires when Application_Status__c changes to "Callback Received"

### Flows
- **Daily_Wellness_Log**: Screen flow for wellness check-ins

### Standard Object Integrations
- **Opportunity**: Tracks job applications through pipeline
- **Account**: Company records for job postings
- **Contact**: Recruiter contact information

## Installation

### Prerequisites
- Salesforce org (Developer, Sandbox, or Production)
- Claude AI API key from Anthropic
- Chrome browser (for extension)

### Setup Steps

1. **Deploy Metadata**
   ```bash
   sf project deploy start --source-dir force-app --target-org YOUR_ORG_ALIAS
   ```

2. **Configure Claude AI Named Credential**
   - Go to Setup → Named Credentials
   - Create new Named Credential for Claude API
   - Add your API key from https://console.anthropic.com/

3. **Configure Opportunity Stages**
   - Follow [OPPORTUNITY_PATH_SETUP_GUIDE.md](OPPORTUNITY_PATH_SETUP_GUIDE.md)
   - Set up Opportunity stages matching your job search pipeline

4. **Set Up Wellness Features (Optional)**
   - Follow [WELLNESS_UI_SETUP_GUIDE.md](WELLNESS_UI_SETUP_GUIDE.md)
   - Create Daily Energy Check-In Flow
   - Add wellness reports and dashboards

5. **Install Chrome Extension**
   - Load extension from `/chrome-extension` directory
   - Configure Salesforce org URL and session ID
   - See `/chrome-extension/INSTALL.md`

## Usage

### Capturing Jobs
1. Browse LinkedIn for jobs
2. Click Chrome extension icon when viewing a job
3. Job automatically sent to Salesforce
4. Claude AI analyzes job within minutes
5. View analysis, fit score, and recommendations in Salesforce

### Managing Applications
1. Update Application_Status__c as you progress
2. When status changes to "Callback Received":
   - Opportunity automatically created
   - Recruiter added as Contact
   - Company added as Account
3. Use Opportunity Path to track progress through pipeline

### Generating Resumes
1. Open job posting record
2. Click "Generate Resume" button
3. Select resume template
4. AI generates customized resume and cover letter
5. Download as PDF or copy to clipboard

### Wellness Tracking
1. Run Daily Energy Check-In Flow each morning
2. Log energy level, mood, and morning routine completion
3. Get personalized schedule recommendations
4. View trends in wellness reports

## Configuration

### Custom Metadata
- **JobSource__mdt**: (Future) Configure job board provider integrations

### Custom Settings
- Configure AI analysis parameters
- Set resume generation templates
- Adjust wellness tracking preferences

## Project Structure
```
force-app/main/default/
├── classes/
│   ├── ClaudeAPIService.cls        # Claude AI integration
│   ├── JobPostingAPI.cls           # REST API for Chrome extension
│   ├── JobPostingAnalyzer.cls      # Job analysis logic
│   ├── ResumeGenerator.cls         # Resume generation
│   ├── OpportunityCreationHandler.cls  # Opportunity automation
│   ├── EnergyAdaptiveScheduler.cls # Wellness scheduling
│   └── DailyRoutineInvocable.cls   # Flow-callable methods
├── triggers/
│   └── OpportunityCreationTrigger.trigger
├── objects/
│   ├── Job_Posting__c/
│   ├── Resume_Package__c/
│   ├── Master_Resume__c/
│   ├── Daily_Routine__c/
│   ├── Opportunity/fields/
│   └── Contact/fields/
├── flows/
│   └── Daily_Wellness_Log.flow-meta.xml
└── lwc/
    └── (Future Lightning Web Components)
```

## API Documentation

### REST API Endpoint
**URL**: `/services/apexrest/jobposting`

**Method**: POST

**Request Body**:
```json
{
  "title": "Senior Salesforce Developer",
  "company": "Acme Corp",
  "location": "Remote - USA",
  "description": "Job description text...",
  "applyUrl": "https://...",
  "provider": "LinkedIn",
  "externalId": "12345",
  "salaryMin": "120000",
  "salaryMax": "150000",
  "recruiterName": "Jane Smith",
  "recruiterEmail": "jane@acme.com",
  "recruiterLinkedIn": "https://linkedin.com/in/janesmith"
}
```

**Response**:
```json
{
  "success": true,
  "jobId": "a015g00000ABCDE",
  "message": "Job posting created successfully! Claude is analyzing it now."
}
```

## Testing

Run all tests:
```bash
sf apex run test --test-level RunLocalTests --target-org YOUR_ORG_ALIAS
```

Key test classes:
- `ClaudeAPIServiceTest`
- `JobPostingAnalyzerTest`
- `ResumeGeneratorTest`
- `OpportunityCreationHandlerTest`
- `EnergyAdaptiveSchedulerTest`
- `DailyRoutineInvocableTest`

## Roadmap

### Planned Features
- [ ] Lightning Web Components UI
- [ ] Mobile app integration
- [ ] Email notifications for new opportunities
- [ ] Interview scheduling integration
- [ ] Salary negotiation assistant
- [ ] Network mapping (visualize recruiter connections)
- [ ] Multi-provider job ingestion (Indeed, Dice, etc.)

### Future Enhancements
- [ ] Machine learning for job fit prediction
- [ ] Interview preparation with Claude AI
- [ ] Application deadline reminders
- [ ] Job market analytics
- [ ] Skills gap analysis

## Contributing

This is a personal project, but suggestions and feedback are welcome! Open an issue to discuss potential changes.

## License

MIT License - See LICENSE file for details

## Author

Abby Luggery
- GitHub: [@abbyluggery](https://github.com/abbyluggery)
- LinkedIn: [Your LinkedIn Profile]

## Acknowledgments

- Built with [Claude AI](https://claude.ai) by Anthropic
- Chrome Extension architecture inspired by LinkedIn scraper patterns
- Salesforce DX project structure
- Wellness tracking inspired by energy management principles

## Support

For questions or issues:
1. Check the documentation in `/docs` folder
2. Review setup guides: OPPORTUNITY_PATH_SETUP_GUIDE.md, WELLNESS_UI_SETUP_GUIDE.md
3. Open an issue on GitHub

---

**Note**: This project requires a Claude AI API key. Sign up at https://console.anthropic.com/

**Privacy**: Job data is stored in your Salesforce org. Claude AI receives job descriptions for analysis but does not store them long-term. Review Anthropic's privacy policy for details.
