/**
 * @description Energy Scheduler UI - Visualize optimal times for activities based on energy patterns
 * @author Abby Luggery / Claude Code Assistant
 * @date November 16, 2025
 */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOptimalTimes from '@salesforce/apex/EnergyAdaptiveScheduler.getOptimalTimesForActivities';
import analyzePatterns from '@salesforce/apex/EnergyAdaptiveScheduler.analyzeEnergyPatterns';
import getRecommendations from '@salesforce/apex/EnergyAdaptiveScheduler.getRecommendations';

export default class EnergySchedulerUI extends LightningElement {
    @track optimalTimes;
    @track patterns;
    @track recommendations = '';
    @track isLoading = false;
    @track error;

    // Current inputs for manual recommendations
    @track currentEnergyLevel = 5;
    @track currentMood = 'Neutral';

    // Mood options
    moodOptions = [
        { label: 'Anxious', value: 'Anxious' },
        { label: 'Stressed', value: 'Stressed' },
        { label: 'Neutral', value: 'Neutral' },
        { label: 'Calm', value: 'Calm' },
        { label: 'Happy', value: 'Happy' },
        { label: 'Energized', value: 'Energized' }
    ];

    connectedCallback() {
        this.loadOptimalTimes();
        this.loadPatterns();
    }

    loadOptimalTimes() {
        this.isLoading = true;

        getOptimalTimes()
            .then(result => {
                this.optimalTimes = this.parseOptimalTimes(result);
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.optimalTimes = undefined;
                console.error('Error loading optimal times:', error);
                this.showToast('Error', 'Failed to load optimal activity times', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadPatterns() {
        analyzePatterns()
            .then(result => {
                this.patterns = result;

                // Load recommendations based on current patterns
                if (this.patterns && this.patterns.currentEnergyLevel && this.patterns.currentMood) {
                    this.currentEnergyLevel = this.patterns.currentEnergyLevel;
                    this.currentMood = this.patterns.currentMood;
                    this.loadRecommendations();
                }
            })
            .catch(error => {
                console.error('Error loading patterns:', error);
            });
    }

    loadRecommendations() {
        getRecommendations({
            energyLevel: parseInt(this.currentEnergyLevel),
            mood: this.currentMood
        })
            .then(result => {
                this.recommendations = result;
            })
            .catch(error => {
                console.error('Error loading recommendations:', error);
            });
    }

    parseOptimalTimes(rawData) {
        if (!rawData) return null;

        // Convert the string result to a structured object
        const activities = [
            { name: 'Deep Work', icon: 'utility:custom_apps', color: '#0176d3' },
            { name: 'Creative Tasks', icon: 'utility:brush', color: '#e97516' },
            { name: 'Meetings', icon: 'utility:groups', color: '#06a59a' },
            { name: 'Administrative', icon: 'utility:form', color: '#939393' },
            { name: 'Learning', icon: 'utility:knowledge_base', color: '#8b5cf6' }
        ];

        // Parse the recommendations from the string
        const lines = rawData.split('\n');
        const parsed = activities.map((activity, index) => {
            // Find the line that mentions this activity
            const activityLine = lines.find(line =>
                line.toLowerCase().includes(activity.name.toLowerCase())
            );

            let timeSlot = 'Not enough data';
            if (activityLine) {
                // Extract time slot from line (e.g., "9-11 AM")
                const timeMatch = activityLine.match(/\d{1,2}(?::\d{2})?\s*(?:AM|PM)\s*-\s*\d{1,2}(?::\d{2})?\s*(?:AM|PM)/i);
                if (timeMatch) {
                    timeSlot = timeMatch[0];
                }
            }

            return {
                ...activity,
                timeSlot: timeSlot,
                id: `activity-${index}`
            };
        });

        return parsed;
    }

    handleEnergyChange(event) {
        this.currentEnergyLevel = event.target.value;
        this.loadRecommendations();
    }

    handleMoodChange(event) {
        this.currentMood = event.target.value;
        this.loadRecommendations();
    }

    handleRefresh() {
        this.loadOptimalTimes();
        this.loadPatterns();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Computed properties
    get hasOptimalTimes() {
        return this.optimalTimes && this.optimalTimes.length > 0;
    }

    get hasPatterns() {
        return this.patterns !== undefined && this.patterns !== null;
    }

    get hasRecommendations() {
        return this.recommendations && this.recommendations.length > 0;
    }

    get averageEnergyFormatted() {
        if (!this.patterns || !this.patterns.averageEnergy) return 'N/A';
        return this.patterns.averageEnergy.toFixed(1);
    }

    get peakEnergyTime() {
        if (!this.patterns || !this.patterns.peakEnergyTime) return 'Not enough data';
        return this.patterns.peakEnergyTime;
    }

    get lowEnergyTime() {
        if (!this.patterns || !this.patterns.lowEnergyTime) return 'Not enough data';
        return this.patterns.lowEnergyTime;
    }

    get energyLevelLabel() {
        const levels = ['', 'Very Low', 'Low', 'Low-Medium', 'Below Average', 'Average',
                       'Above Average', 'Good', 'High', 'Very High', 'Peak'];
        return levels[parseInt(this.currentEnergyLevel)] || 'Average';
    }

    get energyBarClass() {
        const level = parseInt(this.currentEnergyLevel);
        if (level >= 8) return 'energy-bar high';
        if (level >= 5) return 'energy-bar medium';
        return 'energy-bar low';
    }

    get daysAnalyzed() {
        if (!this.patterns || !this.patterns.daysAnalyzed) return 0;
        return this.patterns.daysAnalyzed;
    }

    get hasEnoughData() {
        return this.daysAnalyzed >= 7;
    }

    get dataMessage() {
        if (this.daysAnalyzed === 0) {
            return 'No wellness data found. Start tracking your daily energy levels to get personalized recommendations.';
        } else if (this.daysAnalyzed < 7) {
            return `Analyzing ${this.daysAnalyzed} days of data. Track ${7 - this.daysAnalyzed} more days for better recommendations.`;
        }
        return `Based on ${this.daysAnalyzed} days of wellness data`;
    }

    get mostProductiveMood() {
        if (!this.patterns || !this.patterns.mostProductiveMood) return 'N/A';
        return this.patterns.mostProductiveMood;
    }
}
