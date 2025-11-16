/**
 * @description Wellness Tracker LWC - Daily wellness check-in component
 * @author Abby Luggery / Claude Code Assistant
 * @date November 16, 2025
 */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getTodayRoutine from '@salesforce/apex/DailyRoutineInvocable.getTodayRoutine';
import saveDailyRoutine from '@salesforce/apex/DailyRoutineInvocable.logDailyRoutine';
import getRecommendations from '@salesforce/apex/EnergyAdaptiveScheduler.getRecommendations';

export default class WellnessTracker extends LightningElement {
    @track routineId;
    @track morningRoutineComplete = false;
    @track energyLevel = 5;
    @track moodLevel = 5;
    @track selectedMood = '';
    @track stressLevel = 5;
    @track sleepHours = 7;
    @track sleepQuality = '';
    @track notes = '';
    @track tasksCompleted = 0;
    @track tasksPlanned = 0;

    @track recommendations = '';
    @track isLoading = false;
    @track isSaving = false;
    @track hasLoadedToday = false;

    wiredRoutineResult;

    // Mood options
    moodOptions = [
        { label: 'Anxious', value: 'Anxious' },
        { label: 'Stressed', value: 'Stressed' },
        { label: 'Neutral', value: 'Neutral' },
        { label: 'Calm', value: 'Calm' },
        { label: 'Happy', value: 'Happy' },
        { label: 'Energized', value: 'Energized' }
    ];

    // Sleep quality options
    sleepQualityOptions = [
        { label: 'Poor', value: 'Poor' },
        { label: 'Fair', value: 'Fair' },
        { label: 'Good', value: 'Good' },
        { label: 'Excellent', value: 'Excellent' }
    ];

    @wire(getTodayRoutine)
    wiredRoutine(result) {
        this.wiredRoutineResult = result;
        this.isLoading = true;

        if (result.data) {
            if (result.data.length > 0) {
                const routine = result.data[0];
                this.routineId = routine.Id;
                this.morningRoutineComplete = routine.Morning_Routine_Complete__c || false;
                this.energyLevel = routine.Energy_Level__c || 5;
                this.moodLevel = routine.Mood_Level__c || 5;
                this.selectedMood = routine.Mood__c || '';
                this.stressLevel = routine.Stress_Level__c || 5;
                this.sleepHours = routine.Sleep_Hours__c || 7;
                this.sleepQuality = routine.Sleep_Quality__c || '';
                this.notes = routine.Notes__c || '';
                this.tasksCompleted = routine.Tasks_Completed__c || 0;
                this.tasksPlanned = routine.Tasks_Planned__c || 0;

                this.hasLoadedToday = true;

                // Load recommendations
                this.loadRecommendations();
            }
            this.isLoading = false;
        } else if (result.error) {
            this.isLoading = false;
            this.showToast('Error', 'Failed to load today\'s wellness data', 'error');
            console.error('Error loading routine:', result.error);
        }
    }

    // Energy level change
    handleEnergyChange(event) {
        this.energyLevel = event.target.value;
        this.loadRecommendations();
    }

    // Mood level change
    handleMoodLevelChange(event) {
        this.moodLevel = event.target.value;
    }

    // Mood selection change
    handleMoodChange(event) {
        this.selectedMood = event.target.value;
        this.loadRecommendations();
    }

    // Stress level change
    handleStressChange(event) {
        this.stressLevel = event.target.value;
    }

    // Sleep hours change
    handleSleepHoursChange(event) {
        this.sleepHours = event.target.value;
    }

    // Sleep quality change
    handleSleepQualityChange(event) {
        this.sleepQuality = event.target.value;
    }

    // Notes change
    handleNotesChange(event) {
        this.notes = event.target.value;
    }

    // Tasks completed change
    handleTasksCompletedChange(event) {
        this.tasksCompleted = event.target.value;
    }

    // Tasks planned change
    handleTasksPlannedChange(event) {
        this.tasksPlanned = event.target.value;
    }

    // Morning routine checkbox
    handleRoutineToggle(event) {
        this.morningRoutineComplete = event.target.checked;
    }

    // Load recommendations based on energy and mood
    loadRecommendations() {
        if (!this.energyLevel || !this.selectedMood) {
            return;
        }

        getRecommendations({
            energyLevel: parseInt(this.energyLevel),
            mood: this.selectedMood
        })
            .then(result => {
                this.recommendations = result;
            })
            .catch(error => {
                console.error('Error loading recommendations:', error);
            });
    }

    // Save wellness data
    handleSave() {
        this.isSaving = true;

        const params = [{
            routineDate: new Date().toISOString().split('T')[0],
            morningRoutineComplete: this.morningRoutineComplete,
            energyLevel: parseInt(this.energyLevel),
            moodLevel: parseInt(this.moodLevel),
            mood: this.selectedMood,
            stressLevel: parseInt(this.stressLevel),
            sleepHours: parseFloat(this.sleepHours),
            sleepQuality: this.sleepQuality,
            notes: this.notes,
            tasksCompleted: parseInt(this.tasksCompleted) || 0,
            tasksPlanned: parseInt(this.tasksPlanned) || 0
        }];

        saveDailyRoutine({ requests: params })
            .then(results => {
                if (results && results.length > 0 && results[0].isSuccess) {
                    this.routineId = results[0].recordId;
                    this.showToast('Success', 'Wellness data saved successfully!', 'success');
                    this.hasLoadedToday = true;

                    // Refresh the wire
                    return refreshApex(this.wiredRoutineResult);
                } else {
                    throw new Error(results[0].errorMessage || 'Failed to save wellness data');
                }
            })
            .catch(error => {
                this.showToast('Error', 'Failed to save wellness data: ' + error.body.message, 'error');
                console.error('Error saving routine:', error);
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    // Show toast notification
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Computed properties
    get energyLevelLabel() {
        const levels = ['', 'Very Low', 'Low', 'Low-Medium', 'Below Average', 'Average',
                       'Above Average', 'Good', 'High', 'Very High', 'Peak'];
        return levels[parseInt(this.energyLevel)] || 'Average';
    }

    get moodLevelLabel() {
        const levels = ['', 'Very Low', 'Low', 'Fair', 'Below Average', 'Neutral',
                       'Good', 'Very Good', 'Happy', 'Great', 'Excellent'];
        return levels[parseInt(this.moodLevel)] || 'Neutral';
    }

    get stressLevelLabel() {
        const levels = ['', 'None', 'Very Low', 'Low', 'Mild', 'Moderate',
                       'Elevated', 'High', 'Very High', 'Severe', 'Critical'];
        return levels[parseInt(this.stressLevel)] || 'Moderate';
    }

    get energyBarClass() {
        const level = parseInt(this.energyLevel);
        if (level >= 8) return 'energy-bar high';
        if (level >= 5) return 'energy-bar medium';
        return 'energy-bar low';
    }

    get moodBarClass() {
        const level = parseInt(this.moodLevel);
        if (level >= 8) return 'mood-bar high';
        if (level >= 5) return 'mood-bar medium';
        return 'mood-bar low';
    }

    get stressBarClass() {
        const level = parseInt(this.stressLevel);
        if (level >= 8) return 'stress-bar high';
        if (level >= 5) return 'stress-bar medium';
        return 'stress-bar low';
    }

    get taskCompletionRate() {
        if (!this.tasksPlanned || this.tasksPlanned === 0) return 0;
        return Math.round((this.tasksCompleted / this.tasksPlanned) * 100);
    }

    get taskCompletionLabel() {
        return `${this.taskCompletionRate}% Complete`;
    }

    get hasRecommendations() {
        return this.recommendations && this.recommendations.length > 0;
    }

    get saveButtonLabel() {
        return this.hasLoadedToday ? 'Update Wellness Data' : 'Save Wellness Data';
    }

    get pageTitle() {
        const today = new Date();
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        return 'Wellness Check-In - ' + today.toLocaleDateString('en-US', options);
    }
}
