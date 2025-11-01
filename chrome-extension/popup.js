// Popup script - handles UI interactions and form submission

document.addEventListener('DOMContentLoaded', async () => {
  // Load saved configuration
  const config = await chrome.storage.sync.get(['sfUrl', 'sfUsername', 'sfPassword']);

  if (config.sfUrl) {
    document.getElementById('sfUrl').value = config.sfUrl;
  }
  if (config.sfUsername) {
    document.getElementById('sfUsername').value = config.sfUsername;
  }
  if (config.sfPassword) {
    document.getElementById('sfPassword').value = config.sfPassword;
  }

  // Auto-fill job details from current page
  autoFillFromPage();

  // Event listeners
  document.getElementById('captureJob').addEventListener('click', captureJob);
  document.getElementById('autoFill').addEventListener('click', autoFillFromPage);
  document.getElementById('saveConfig').addEventListener('click', saveConfig);
  document.getElementById('showConfig').addEventListener('click', showConfigSection);
  document.getElementById('showJobForm').addEventListener('click', showJobSection);
});

async function autoFillFromPage() {
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

    const results = await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      function: extractJobDetails
    });

    if (results && results[0] && results[0].result) {
      const jobData = results[0].result;

      if (jobData.title) document.getElementById('title').value = jobData.title;
      if (jobData.company) document.getElementById('company').value = jobData.company;
      if (jobData.location) document.getElementById('location').value = jobData.location;
      if (jobData.salary) document.getElementById('salary').value = jobData.salary;
      if (jobData.description) document.getElementById('description').value = jobData.description;

      // Auto-fill recruiter info if found
      if (jobData.recruiterName && document.getElementById('recruiterName')) {
        document.getElementById('recruiterName').value = jobData.recruiterName;
      }
      if (jobData.recruiterEmail && document.getElementById('recruiterEmail')) {
        document.getElementById('recruiterEmail').value = jobData.recruiterEmail;
      }
      if (jobData.recruiterPhone && document.getElementById('recruiterPhone')) {
        document.getElementById('recruiterPhone').value = jobData.recruiterPhone;
      }
      if (jobData.recruiterLinkedIn && document.getElementById('recruiterLinkedIn')) {
        document.getElementById('recruiterLinkedIn').value = jobData.recruiterLinkedIn;
      }
      if (jobData.recruiterTitle && document.getElementById('recruiterTitle')) {
        document.getElementById('recruiterTitle').value = jobData.recruiterTitle;
      }
    }
  } catch (error) {
    console.error('Auto-fill error:', error);
  }
}

async function captureJob() {
  const button = document.getElementById('captureJob');
  const statusDiv = document.getElementById('status');

  button.disabled = true;
  button.textContent = 'Saving...';

  // Get config
  const config = await chrome.storage.sync.get(['sfUrl', 'sfUsername', 'sfPassword']);

  if (!config.sfUrl || !config.sfUsername || !config.sfPassword) {
    showStatus('Please configure Salesforce connection first', 'error');
    button.disabled = false;
    button.textContent = 'Save to Salesforce & Analyze';
    showConfigSection();
    return;
  }

  // Get job details
  const title = document.getElementById('title').value.trim();
  const company = document.getElementById('company').value.trim();
  const location = document.getElementById('location').value.trim();
  const salary = document.getElementById('salary').value.trim();
  const description = document.getElementById('description').value.trim();

  if (!title || !company || !location) {
    showStatus('Please fill in Title, Company, and Location (required fields)', 'error');
    button.disabled = false;
    button.textContent = 'Save to Salesforce & Analyze';
    return;
  }

  // Get current URL and clean it (remove tracking parameters)
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  let applyUrl = tab.url;

  // Clean LinkedIn URLs - remove tracking parameters
  if (applyUrl.includes('linkedin.com')) {
    applyUrl = applyUrl.split('?')[0]; // Remove everything after ?
  }

  // Truncate if still too long (Salesforce limit is usually 255 or 1000 chars)
  if (applyUrl.length > 255) {
    applyUrl = applyUrl.substring(0, 255);
  }

  // Determine provider - must match Salesforce picklist values exactly
  let provider = 'Dice'; // Default to Dice if unknown
  if (applyUrl.includes('linkedin.com')) provider = 'LinkedIn';
  else if (applyUrl.includes('indeed.com')) provider = 'Indeed';
  else if (applyUrl.includes('glassdoor.com')) provider = 'Glassdoor';
  else if (applyUrl.includes('dice.com')) provider = 'Dice';
  else if (applyUrl.includes('flexjobs.com')) provider = 'FlexJobs';
  else if (applyUrl.includes('greenhouse.io')) provider = 'Greenhouse';
  else if (applyUrl.includes('lever.co')) provider = 'Lever';
  else if (applyUrl.includes('theladders.com')) provider = 'Ladders';

  // Parse salary
  let salaryMin = '';
  let salaryMax = '';
  if (salary) {
    const salaryMatch = salary.match(/\$?([\d,]+)\s*[-–to]\s*\$?([\d,]+)/i);
    if (salaryMatch) {
      salaryMin = salaryMatch[1].replace(/,/g, '');
      salaryMax = salaryMatch[2].replace(/,/g, '');
    } else {
      const singleSalary = salary.match(/\$?([\d,]+)/);
      if (singleSalary) {
        salaryMin = singleSalary[1].replace(/,/g, '');
      }
    }
  }

  // Get recruiter info (will be auto-filled if found)
  const recruiterName = document.getElementById('recruiterName')?.value?.trim() || '';
  const recruiterEmail = document.getElementById('recruiterEmail')?.value?.trim() || '';
  const recruiterPhone = document.getElementById('recruiterPhone')?.value?.trim() || '';
  const recruiterLinkedIn = document.getElementById('recruiterLinkedIn')?.value?.trim() || '';
  const recruiterTitle = document.getElementById('recruiterTitle')?.value?.trim() || '';

  // Create job posting request - must match JobPostingRequest wrapper class
  const jobData = {
    title: title,
    company: company,
    location: location,
    description: description,
    applyUrl: applyUrl,
    provider: provider,
    externalId: provider.toLowerCase() + '_' + Date.now(),
    salaryMin: salaryMin || '',
    salaryMax: salaryMax || '',
    currencyCode: 'USD',
    salaryInterval: 'Yearly',
    recruiterName: recruiterName,
    recruiterEmail: recruiterEmail,
    recruiterPhone: recruiterPhone,
    recruiterLinkedIn: recruiterLinkedIn,
    recruiterTitle: recruiterTitle
  };

  try {
    // Send to Salesforce
    const result = await sendToSalesforce(config, jobData);

    if (result.success) {
      showStatus('✅ ' + result.message, 'success');
      // Clear form
      setTimeout(() => {
        window.close();
      }, 2000);
    } else {
      showStatus('❌ ' + result.message, 'error');
    }
  } catch (error) {
    showStatus('❌ Error: ' + error.message, 'error');
  }

  button.disabled = false;
  button.textContent = 'Save to Salesforce & Analyze';
}

async function sendToSalesforce(config, jobData) {
  // Use Session ID/Access Token directly (simpler than OAuth flow)
  const apiUrl = config.sfUrl + '/services/apexrest/jobposting';

  // Get session token from config (will be stored as "password" field)
  const sessionToken = config.sfPassword;

  // Wrap the data in a request object for Salesforce REST API
  const requestBody = {
    request: jobData
  };

  const response = await fetch(apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + sessionToken
    },
    body: JSON.stringify(requestBody)
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error('Failed to save to Salesforce: ' + errorText);
  }

  return await response.json();
}

async function saveConfig() {
  const sfUrl = document.getElementById('sfUrl').value.trim();
  const sfUsername = document.getElementById('sfUsername').value.trim();
  const sfPassword = document.getElementById('sfPassword').value.trim();

  if (!sfUrl || !sfUsername || !sfPassword) {
    showStatus('Please fill in all fields', 'error');
    return;
  }

  await chrome.storage.sync.set({
    sfUrl: sfUrl,
    sfUsername: sfUsername,
    sfPassword: sfPassword
  });

  showStatus('Configuration saved!', 'success');
  setTimeout(showJobSection, 1500);
}

function showConfigSection() {
  document.getElementById('configSection').style.display = 'block';
  document.getElementById('jobSection').style.display = 'none';
}

function showJobSection() {
  document.getElementById('configSection').style.display = 'none';
  document.getElementById('jobSection').style.display = 'block';
}

function showStatus(message, type) {
  const statusDiv = document.getElementById('status');
  statusDiv.textContent = message;
  statusDiv.className = 'status ' + type;
  statusDiv.style.display = 'block';

  if (type === 'success') {
    setTimeout(() => {
      statusDiv.style.display = 'none';
    }, 3000);
  }
}

// This function runs in the context of the job posting page
function extractJobDetails() {
  const hostname = window.location.hostname;
  let jobData = {
    title: '',
    company: '',
    location: '',
    salary: '',
    description: '',
    recruiterName: '',
    recruiterEmail: '',
    recruiterPhone: '',
    recruiterLinkedIn: '',
    recruiterTitle: ''
  };

  // LinkedIn selectors
  if (hostname.includes('linkedin.com')) {
    jobData.title = document.querySelector('.job-details-jobs-unified-top-card__job-title')?.textContent?.trim() ||
                    document.querySelector('.jobs-unified-top-card__job-title')?.textContent?.trim() || '';

    jobData.company = document.querySelector('.job-details-jobs-unified-top-card__company-name')?.textContent?.trim() ||
                      document.querySelector('.jobs-unified-top-card__company-name')?.textContent?.trim() || '';

    jobData.location = document.querySelector('.job-details-jobs-unified-top-card__bullet')?.textContent?.trim() ||
                       document.querySelector('.jobs-unified-top-card__bullet')?.textContent?.trim() || '';

    jobData.salary = document.querySelector('.job-details-jobs-unified-top-card__job-insight')?.textContent?.trim() || '';

    jobData.description = document.querySelector('.jobs-description__content')?.textContent?.trim() ||
                          document.querySelector('.jobs-box__html-content')?.textContent?.trim() || '';

    // Extract recruiter/hiring team information
    const hiringTeam = document.querySelector('.jobs-poster__name')?.textContent?.trim() ||
                       document.querySelector('.hirer-card__hirer-information')?.textContent?.trim() || '';

    const hiringTeamTitle = document.querySelector('.jobs-poster__job-title')?.textContent?.trim() ||
                            document.querySelector('.hirer-card__hirer-title')?.textContent?.trim() || '';

    const hiringTeamLink = document.querySelector('.jobs-poster__name a')?.href ||
                           document.querySelector('.hirer-card__hirer-information a')?.href || '';

    if (hiringTeam) jobData.recruiterName = hiringTeam;
    if (hiringTeamTitle) jobData.recruiterTitle = hiringTeamTitle;
    if (hiringTeamLink && hiringTeamLink.includes('linkedin.com')) jobData.recruiterLinkedIn = hiringTeamLink;

    // Extract contact info from description
    const description = jobData.description;

    // Email patterns
    const emailMatch = description.match(/([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/);
    if (emailMatch) jobData.recruiterEmail = emailMatch[1];

    // Phone patterns (various formats)
    const phoneMatch = description.match(/(?:\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})/);
    if (phoneMatch) jobData.recruiterPhone = phoneMatch[0];

    // LinkedIn profile in description
    const linkedInMatch = description.match(/(https?:\/\/)?(www\.)?linkedin\.com\/in\/[a-zA-Z0-9_-]+\/?/);
    if (linkedInMatch && !jobData.recruiterLinkedIn) jobData.recruiterLinkedIn = linkedInMatch[0];
  }

  // Indeed selectors
  else if (hostname.includes('indeed.com')) {
    jobData.title = document.querySelector('.jobsearch-JobInfoHeader-title')?.textContent?.trim() || '';
    jobData.company = document.querySelector('[data-company-name="true"]')?.textContent?.trim() || '';
    jobData.location = document.querySelector('[data-testid="job-location"]')?.textContent?.trim() || '';
    jobData.salary = document.querySelector('.salary-snippet')?.textContent?.trim() || '';
    jobData.description = document.querySelector('#jobDescriptionText')?.textContent?.trim() || '';
  }

  // Glassdoor selectors
  else if (hostname.includes('glassdoor.com')) {
    jobData.title = document.querySelector('[data-test="job-title"]')?.textContent?.trim() || '';
    jobData.company = document.querySelector('[data-test="employer-name"]')?.textContent?.trim() || '';
    jobData.location = document.querySelector('[data-test="location"]')?.textContent?.trim() || '';
    jobData.salary = document.querySelector('[data-test="detailSalary"]')?.textContent?.trim() || '';
    jobData.description = document.querySelector('.desc')?.textContent?.trim() || '';
  }

  // Generic fallback - try common patterns
  if (!jobData.title) {
    jobData.title = document.querySelector('h1')?.textContent?.trim() || '';
  }

  return jobData;
}
