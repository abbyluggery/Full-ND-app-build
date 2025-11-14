import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

// Import Apex methods
import startSession from '@salesforce/apex/InterviewPrepController.startSession';
import getAllSessions from '@salesforce/apex/InterviewPrepController.getAllSessions';
import getNextQuestion from '@salesforce/apex/InterviewPrepController.getNextQuestion';
import submitResponse from '@salesforce/apex/InterviewPrepController.submitResponse';
import endSession from '@salesforce/apex/InterviewPrepController.endSession';

export default class InterviewPrepAgent extends LightningElement {
    @api recordId; // Job_Posting__c or Opportunity Id

    // Session state
    @track currentSessionId;
    @track currentQuestion;
    @track latestResponse;
    @track previousSessions = [];
    @track userResponse = '';
    @track responseTime = 0;
    @track isLoading = false;
    @track isSubmitting = false;
    @track errorMessage = '';

    // Timer
    responseTimer;
    startTime;

    // Computed properties
    get hasActiveSession() {
        return this.currentSessionId != null && this.currentQuestion != null;
    }

    get hasFeedback() {
        return this.latestResponse != null;
    }

    get hasPreviousSessions() {
        return this.previousSessions && this.previousSessions.length > 0;
    }

    get totalQuestions() {
        // Placeholder - could be fetched from session
        return 10;
    }

    // Load previous sessions on component load
    connectedCallback() {
        this.loadPreviousSessions();
    }

    disconnectedCallback() {
        this.stopTimer();
    }

    // Load all previous sessions for this record
    loadPreviousSessions() {
        getAllSessions({ recordId: this.recordId })
            .then(result => {
                this.previousSessions = result.map(session => {
                    return {
                        ...session,
                        formattedDate: new Date(session.Session_Date__c).toLocaleDateString(),
                        statusClass: this.getStatusClass(session.Session_Status__c)
                    };
                });
            })
            .catch(error => {
                this.handleError('Error loading sessions', error);
            });
    }

    // Get CSS class based on session status
    getStatusClass(status) {
        switch(status) {
            case 'Completed':
                return 'slds-badge_success';
            case 'In Progress':
                return 'slds-badge_warning';
            default:
                return '';
        }
    }

    // Start session handlers
    startBehavioralSession() {
        this.startNewSession('Behavioral');
    }

    startTechnicalSession() {
        this.startNewSession('Technical');
    }

    startSituationalSession() {
        this.startNewSession('Situational');
    }

    startCultureFitSession() {
        this.startNewSession('Culture Fit');
    }

    // Start a new interview session
    startNewSession(sessionType) {
        this.isLoading = true;
        this.errorMessage = '';

        startSession({ recordId: this.recordId, sessionType: sessionType })
            .then(sessionId => {
                this.currentSessionId = sessionId;
                this.showToast('Success', `${sessionType} session started!`, 'success');
                return this.loadNextQuestion();
            })
            .catch(error => {
                this.handleError('Error starting session', error);
                this.isLoading = false;
            });
    }

    // Load the next question
    loadNextQuestion() {
        this.isLoading = true;
        this.errorMessage = '';
        this.latestResponse = null;
        this.userResponse = '';
        this.stopTimer();

        getNextQuestion({ sessionId: this.currentSessionId })
            .then(question => {
                this.currentQuestion = question;
                this.startTimer();
                this.isLoading = false;
            })
            .catch(error => {
                this.handleError('Error loading question', error);
                this.isLoading = false;
            });
    }

    // Handle user response text input
    handleResponseChange(event) {
        this.userResponse = event.target.value;
    }

    // Submit user's response
    submitResponse() {
        if (!this.userResponse || this.userResponse.trim() === '') {
            this.showToast('Error', 'Please enter a response', 'error');
            return;
        }

        this.isSubmitting = true;
        this.errorMessage = '';
        const responseTimeInSeconds = this.responseTime;

        submitResponse({
            sessionId: this.currentSessionId,
            questionId: this.currentQuestion.Id,
            userResponse: this.userResponse,
            responseTimeSeconds: responseTimeInSeconds
        })
            .then(response => {
                this.latestResponse = response;
                this.stopTimer();
                this.isSubmitting = false;
                this.showToast('Success', 'Response submitted!', 'success');
            })
            .catch(error => {
                this.handleError('Error submitting response', error);
                this.isSubmitting = false;
            });
    }

    // Get next question after viewing feedback
    getNextQuestion() {
        this.loadNextQuestion();
    }

    // End the current session
    endSession() {
        if (!confirm('Are you sure you want to end this session?')) {
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        endSession({ sessionId: this.currentSessionId })
            .then(summary => {
                this.showToast('Session Complete',
                    `Final Score: ${summary.overallScore}/100`,
                    'success');
                this.currentSessionId = null;
                this.currentQuestion = null;
                this.latestResponse = null;
                this.stopTimer();
                this.loadPreviousSessions();
                this.isLoading = false;
            })
            .catch(error => {
                this.handleError('Error ending session', error);
                this.isLoading = false;
            });
    }

    // Timer management
    startTimer() {
        this.responseTime = 0;
        this.startTime = Date.now();
        this.responseTimer = setInterval(() => {
            this.responseTime = Math.floor((Date.now() - this.startTime) / 1000);
        }, 1000);
    }

    stopTimer() {
        if (this.responseTimer) {
            clearInterval(this.responseTimer);
            this.responseTimer = null;
        }
    }

    // Error handling
    handleError(title, error) {
        console.error(title, error);
        this.errorMessage = error.body ? error.body.message : error.message;
        this.showToast(title, this.errorMessage, 'error');
    }

    // Toast notifications
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}
