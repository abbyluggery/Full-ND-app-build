// Content script - runs on job posting pages
// This adds functionality directly to the job board pages

// Add a floating button to the page for quick capture
function addCaptureButton() {
  // Don't add if already exists
  if (document.getElementById('sf-job-capture-btn')) {
    return;
  }

  const button = document.createElement('button');
  button.id = 'sf-job-capture-btn';
  button.innerHTML = '💼 Save to SF';
  button.style.cssText = `
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 999999;
    padding: 12px 20px;
    background: #0176d3;
    color: white;
    border: none;
    border-radius: 25px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    transition: all 0.3s ease;
  `;

  button.addEventListener('mouseenter', () => {
    button.style.background = '#014486';
    button.style.transform = 'scale(1.05)';
  });

  button.addEventListener('mouseleave', () => {
    button.style.background = '#0176d3';
    button.style.transform = 'scale(1)';
  });

  button.addEventListener('click', () => {
    // Open extension popup programmatically
    chrome.runtime.sendMessage({ action: 'openPopup' });
  });

  document.body.appendChild(button);
}

// Add the button when page loads
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', addCaptureButton);
} else {
  addCaptureButton();
}

// Listen for messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getJobDetails') {
    // This would be called if we need to extract job details
    sendResponse({ success: true });
  }
});
