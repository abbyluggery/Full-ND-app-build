import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getPlannedMeals from '@salesforce/apex/MealPlanCalendarController.getPlannedMeals';
import generateMealPlan from '@salesforce/apex/MealPlanCalendarController.generateMealPlan';

export default class MealPlanCalendar extends LightningElement {
    @api recordId; // Weekly_Meal_Plan__c record ID
    @track mealPlanData;
    @track isLoading = false;
    @track showGenerateDialog = false;

    // Calendar state
    @track calendarWeeks = [];
    @track selectedMeal;

    // Meal plan metadata
    startDate;
    endDate;
    numberOfPeople = 5;

    wiredMealsResult;

    @wire(getPlannedMeals, { mealPlanId: '$recordId' })
    wiredMeals(result) {
        this.wiredMealsResult = result;
        if (result.data) {
            this.processMealData(result.data);
        } else if (result.error) {
            this.showError('Error loading meal plan', result.error);
        }
    }

    processMealData(data) {
        this.mealPlanData = data;
        this.startDate = data.startDate;
        this.endDate = data.endDate;
        this.numberOfPeople = data.numberOfPeople;

        // Build 2-week calendar grid
        this.buildCalendar(data.plannedMeals);
    }

    buildCalendar(plannedMeals) {
        const weeks = [];
        const mealsByDate = this.groupMealsByDate(plannedMeals);

        // Create 2 weeks of 7 days each
        let currentDate = new Date(this.startDate);

        for (let weekNum = 0; weekNum < 2; weekNum++) {
            const week = {
                weekNumber: weekNum + 1,
                days: []
            };

            for (let dayNum = 0; dayNum < 7; dayNum++) {
                const dateKey = this.formatDate(currentDate);
                const dayMeals = mealsByDate[dateKey] || [];

                week.days.push({
                    date: new Date(currentDate),
                    dateKey: dateKey,
                    dayName: this.getDayName(currentDate),
                    dayNumber: currentDate.getDate(),
                    breakfast: dayMeals.find(m => m.mealTime === 'Breakfast'),
                    lunch: dayMeals.find(m => m.mealTime === 'Lunch'),
                    dinner: dayMeals.find(m => m.mealTime === 'Dinner')
                });

                currentDate.setDate(currentDate.getDate() + 1);
            }

            weeks.push(week);
        }

        this.calendarWeeks = weeks;
    }

    groupMealsByDate(meals) {
        const grouped = {};

        meals.forEach(meal => {
            const dateKey = meal.mealDate;
            if (!grouped[dateKey]) {
                grouped[dateKey] = [];
            }
            grouped[dateKey].push(meal);
        });

        return grouped;
    }

    formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    getDayName(date) {
        const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        return days[date.getDay()];
    }

    // Event handlers
    handleMealClick(event) {
        const mealId = event.currentTarget.dataset.mealId;
        const mealTime = event.currentTarget.dataset.mealTime;
        const dateKey = event.currentTarget.dataset.date;

        // Find the selected meal
        const week = this.calendarWeeks.find(w =>
            w.days.some(d => d.dateKey === dateKey)
        );

        if (week) {
            const day = week.days.find(d => d.dateKey === dateKey);
            this.selectedMeal = day[mealTime.toLowerCase()];

            // Dispatch event to parent component or show modal
            this.dispatchEvent(new CustomEvent('mealselected', {
                detail: { meal: this.selectedMeal }
            }));
        }
    }

    handleGeneratePlan() {
        this.showGenerateDialog = true;
    }

    handleConfirmGenerate() {
        this.isLoading = true;
        this.showGenerateDialog = false;

        generateMealPlan({
            startDate: this.startDate,
            numberOfPeople: this.numberOfPeople
        })
        .then(result => {
            this.showSuccess('Meal Plan Generated', 'Your 2-week meal plan has been created successfully!');
            return refreshApex(this.wiredMealsResult);
        })
        .catch(error => {
            this.showError('Error generating meal plan', error);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    handleCancelGenerate() {
        this.showGenerateDialog = false;
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.wiredMealsResult)
            .finally(() => {
                this.isLoading = false;
            });
    }

    // Helper methods
    showSuccess(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success'
        }));
    }

    showError(title, error) {
        let message = 'An unknown error occurred';
        if (error && error.body) {
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (error.body.message) {
                message = error.body.message;
            }
        }

        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error',
            mode: 'sticky'
        }));
    }

    // Getters
    get hasData() {
        return this.calendarWeeks && this.calendarWeeks.length > 0;
    }

    get formattedDateRange() {
        if (this.startDate && this.endDate) {
            return `${this.formatDateDisplay(this.startDate)} - ${this.formatDateDisplay(this.endDate)}`;
        }
        return '';
    }

    formatDateDisplay(dateStr) {
        const date = new Date(dateStr);
        const options = { month: 'short', day: 'numeric', year: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    }
}
