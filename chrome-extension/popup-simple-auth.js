// Simplified authentication version - uses simple bearer token approach
// This bypasses the OAuth username-password flow issues

async function sendToSalesforce(config, jobData) {
  // Direct API call using session-based approach
  const apiUrl = config.sfUrl + '/services/apexrest/jobposting';

  // We'll use a simpler approach - get a session ID from Salesforce and use that
  // This requires the user to be logged into Salesforce in another tab

  try {
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      credentials: 'include', // This sends cookies from Salesforce login
      body: JSON.stringify(jobData)
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error('Failed to save: ' + errorText);
    }

    return await response.json();
  } catch (error) {
    throw error;
  }
}
