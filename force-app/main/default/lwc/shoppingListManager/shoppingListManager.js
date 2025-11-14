import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getShoppingLists from '@salesforce/apex/ShoppingListController.getShoppingLists';
import toggleItemPurchased from '@salesforce/apex/ShoppingListController.toggleItemPurchased';
import generateShoppingLists from '@salesforce/apex/ShoppingListController.generateShoppingLists';
import matchCoupons from '@salesforce/apex/ShoppingListController.matchCoupons';

export default class ShoppingListManager extends LightningElement {
    @api recordId; // Weekly_Meal_Plan__c ID
    @track shoppingLists = [];
    @track isLoading = false;
    @track selectedStore = 'All';
    @track showCouponPanel = false;

    wiredShoppingListsResult;

    @wire(getShoppingLists, { mealPlanId: '$recordId' })
    wiredShoppingLists(result) {
        this.wiredShoppingListsResult = result;
        if (result.data) {
            this.processShoppingLists(result.data);
        } else if (result.error) {
            this.showError('Error loading shopping lists', result.error);
        }
    }

    processShoppingLists(data) {
        this.shoppingLists = data.map(list => ({
            ...list,
            itemsByCategory: this.groupItemsByCategory(list.items),
            totalItems: list.items.length,
            purchasedCount: list.items.filter(item => item.isPurchased).length,
            totalCost: this.calculateTotal(list.items),
            totalSavings: this.calculateSavings(list.items),
            progressPercent: this.calculateProgress(list.items)
        }));
    }

    groupItemsByCategory(items) {
        const grouped = {};
        items.forEach(item => {
            const category = item.category || 'Other';
            if (!grouped[category]) {
                grouped[category] = [];
            }
            grouped[category].push(item);
        });

        // Convert to array format for template
        return Object.keys(grouped).map(category => ({
            category: category,
            items: grouped[category]
        }));
    }

    calculateTotal(items) {
        return items.reduce((sum, item) => {
            return sum + (item.estimatedPrice || 0);
        }, 0);
    }

    calculateSavings(items) {
        return items.reduce((sum, item) => {
            return sum + (item.couponDiscount || 0);
        }, 0);
    }

    calculateProgress(items) {
        if (items.length === 0) return 0;
        const purchased = items.filter(item => item.isPurchased).length;
        return Math.round((purchased / items.length) * 100);
    }

    // Event Handlers
    handleStoreFilter(event) {
        this.selectedStore = event.target.value;
    }

    handleItemToggle(event) {
        const itemId = event.currentTarget.dataset.itemId;
        this.isLoading = true;

        toggleItemPurchased({ itemId: itemId })
            .then(() => {
                return refreshApex(this.wiredShoppingListsResult);
            })
            .catch(error => {
                this.showError('Error updating item', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleGenerateLists() {
        this.isLoading = true;

        generateShoppingLists({ mealPlanId: this.recordId })
            .then(result => {
                this.showSuccess(
                    'Shopping Lists Generated',
                    `Created ${result.length} shopping list(s)`
                );
                return refreshApex(this.wiredShoppingListsResult);
            })
            .catch(error => {
                this.showError('Error generating shopping lists', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleMatchCoupons() {
        this.isLoading = true;

        const listIds = this.shoppingLists.map(list => list.id);

        matchCoupons({ shoppingListIds: listIds })
            .then(result => {
                this.showSuccess(
                    'Coupons Matched',
                    `Found ${result.itemsWithCoupons} items with available coupons. Total savings: $${result.totalSavings.toFixed(2)}`
                );
                return refreshApex(this.wiredShoppingListsResult);
            })
            .catch(error => {
                this.showError('Error matching coupons', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleToggleCouponPanel() {
        this.showCouponPanel = !this.showCouponPanel;
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.wiredShoppingListsResult)
            .finally(() => {
                this.isLoading = false;
            });
    }

    // Helper Methods
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
    get hasShoppingLists() {
        return this.shoppingLists && this.shoppingLists.length > 0;
    }

    get filteredShoppingLists() {
        if (this.selectedStore === 'All') {
            return this.shoppingLists;
        }
        return this.shoppingLists.filter(list => list.store === this.selectedStore);
    }

    get storeOptions() {
        return [
            { label: 'All Stores', value: 'All' },
            { label: 'Publix', value: 'Publix' },
            { label: 'Walmart', value: 'Walmart' },
            { label: 'Costco', value: 'Costco' }
        ];
    }

    get totalItemsAcrossLists() {
        if (!this.shoppingLists || !Array.isArray(this.shoppingLists)) {
            return 0;
        }
        return this.shoppingLists.reduce((sum, list) => {
            return sum + (list.totalItems || 0);
        }, 0);
    }

    get totalCostAcrossLists() {
        if (!this.shoppingLists || !Array.isArray(this.shoppingLists)) {
            return '0.00';
        }
        const total = this.shoppingLists.reduce((sum, list) => {
            const cost = typeof list.totalCost === 'number' ? list.totalCost : 0;
            return sum + cost;
        }, 0);
        return total.toFixed(2);
    }

    get totalSavingsAcrossLists() {
        if (!this.shoppingLists || !Array.isArray(this.shoppingLists)) {
            return '0.00';
        }
        const total = this.shoppingLists.reduce((sum, list) => {
            const savings = typeof list.totalSavings === 'number' ? list.totalSavings : 0;
            return sum + savings;
        }, 0);
        return total.toFixed(2);
    }
}
