// Background service worker
// Handles extension lifecycle and background tasks

chrome.runtime.onInstalled.addListener(() => {
  console.log('Job Search Assistant installed!');
});

// Listen for messages from content script or popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'openPopup') {
    // Open the extension popup
    chrome.action.openPopup();
  }
});

// Optional: Add context menu item for right-click capture
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'captureJob',
    title: 'Save job to Salesforce',
    contexts: ['page', 'selection']
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === 'captureJob') {
    // Open popup
    chrome.action.openPopup();
  }
});
