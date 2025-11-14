/**
 * @description Holistic Life Dashboard - Unified view across all 4 platforms
 * @author Abby Luggery / Claude Code Assistant
 * @date November 12, 2025
 */
import { LightningElement, wire, track } from 'lwc';
import getDashboardData from '@salesforce/apex/HolisticDashboardController.getDashboardData';
import { refreshApex } from '@salesforce/apex';

export default class HolisticDashboard extends LightningElement {
    @track dashboardData;
    @track error;
    @track isLoading = true;
    wiredDashboardResult;

    // Dashboard sections visibility
    @track showJobSearch = true;
    @track showMealPlanning = true;
    @track showShopping = true;
    @track showWellness = true;

    @wire(getDashboardData)
    wiredDashboard(result) {
        this.wiredDashboardResult = result;
        if (result.data) {
            this.dashboardData = result.data;
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
            this.dashboardData = undefined;
            this.isLoading = false;
            console.error('Dashboard error:', result.error);
        }
    }

    // Job Search Section Data
    get jobSearchStats() {
        if (!this.dashboardData || !this.dashboardData.jobSearch) return null;
        return this.dashboardData.jobSearch;
    }

    get hasJobSearchData() {
        return this.jobSearchStats &&
               (this.jobSearchStats.totalJobs > 0 ||
                this.jobSearchStats.applicationsThisWeek > 0);
    }

    get jobSearchPipeline() {
        if (!this.jobSearchStats) return [];
        return [
            { stage: 'Discovered', count: this.jobSearchStats.jobsDiscovered || 0 },
            { stage: 'Researching', count: this.jobSearchStats.jobsResearching || 0 },
            { stage: 'Applied', count: this.jobSearchStats.jobsApplied || 0 },
            { stage: 'Interviewing', count: this.jobSearchStats.jobsInterviewing || 0 },
            { stage: 'Offers', count: this.jobSearchStats.jobsOffers || 0 }
        ];
    }

    get upcomingInterviews() {
        return this.dashboardData?.upcomingInterviews || [];
    }

    get hasUpcomingInterviews() {
        return this.upcomingInterviews.length > 0;
    }

    // Meal Planning Section Data
    get mealPlanningStats() {
        if (!this.dashboardData || !this.dashboardData.mealPlanning) return null;
        return this.dashboardData.mealPlanning;
    }

    get hasMealPlanningData() {
        return this.mealPlanningStats && this.mealPlanningStats.activePlanId;
    }

    get thisWeekMeals() {
        return this.dashboardData?.thisWeekMeals || [];
    }

    get mealCompletionPercent() {
        if (!this.mealPlanningStats) return 0;
        const total = this.mealPlanningStats.totalMealsThisWeek || 21; // 7 days × 3 meals
        const completed = this.mealPlanningStats.completedMealsThisWeek || 0;
        return Math.round((completed / total) * 100);
    }

    // Shopping Section Data
    get shoppingStats() {
        if (!this.dashboardData || !this.dashboardData.shopping) return null;
        return this.dashboardData.shopping;
    }

    get hasShoppingData() {
        return this.shoppingStats && this.shoppingStats.listsReady > 0;
    }

    get estimatedSavings() {
        if (!this.shoppingStats) return 0;
        return this.shoppingStats.estimatedSavings || 0;
    }

    get couponCount() {
        if (!this.shoppingStats) return 0;
        return this.shoppingStats.activeCoupons || 0;
    }

    // Wellness Section Data
    get wellnessStats() {
        if (!this.dashboardData || !this.dashboardData.wellness) return null;
        return this.dashboardData.wellness;
    }

    get hasWellnessData() {
        return this.wellnessStats && this.wellnessStats.todayMood;
    }

    get moodEmoji() {
        if (!this.wellnessStats || !this.wellnessStats.todayMood) return '😐';
        const moodMap = {
            'Anxious': '😰',
            'Stressed': '😓',
            'Neutral': '😐',
            'Calm': '😌',
            'Happy': '😊',
            'Energized': '🤩'
        };
        return moodMap[this.wellnessStats.todayMood] || '😐';
    }

    get energyLevel() {
        if (!this.wellnessStats) return 0;
        return this.wellnessStats.todayEnergy || 0;
    }

    get energyBarWidth() {
        return `width: ${this.energyLevel * 10}%`;
    }

    get stressVariant() {
        if (!this.wellnessStats) return 'base';
        const stress = this.wellnessStats.todayStress || 0;
        if (stress >= 70) return 'expired';
        if (stress >= 40) return 'warning';
        return 'base';
    }

    get routineComplete() {
        if (!this.wellnessStats) return false;
        return this.wellnessStats.morningRoutineComplete || false;
    }

    // Actions
    handleRefresh() {
        this.isLoading = true;
        return refreshApex(this.wiredDashboardResult);
    }

    toggleJobSearchSection() {
        this.showJobSearch = !this.showJobSearch;
    }

    toggleMealPlanningSection() {
        this.showMealPlanning = !this.showMealPlanning;
    }

    toggleShoppingSection() {
        this.showShopping = !this.showShopping;
    }

    toggleWellnessSection() {
        this.showWellness = !this.showWellness;
    }

    // Navigation actions
    navigateToJobSearch() {
        // Navigate to Job Search app
        window.location.href = '/lightning/o/Job_Posting__c/list';
    }

    navigateToMealPlanning() {
        // Navigate to Meal Planning
        window.location.href = '/lightning/o/Weekly_Meal_Plan__c/list';
    }

    navigateToShopping() {
        // Navigate to Shopping Lists
        window.location.href = '/lightning/o/Shopping_List__c/list';
    }

    navigateToWellness() {
        // Navigate to Daily Routine
        window.location.href = '/lightning/o/Daily_Routine__c/list';
    }

    // Helper getters
    get formattedCurrency() {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        });
    }
}
