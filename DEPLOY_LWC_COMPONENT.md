# Deploy shoppingListManager Component - Developer Console Method

Since the component doesn't appear in your Developer Console's Lightning Resources, we need to create it fresh. Here's the step-by-step process:

---

## Step 1: Create the Component Bundle

1. **Open Salesforce** in your browser
2. Click the **gear icon (⚙️)** → **Developer Console**
3. **File → New → Lightning Component**
4. In the dialog:
   - **Name:** `shoppingListManager`
   - **Component Configuration:**
     - ✅ Lightning Page
     - ✅ Lightning Record Page
     - ✅ Lightning Tab
5. Click **Submit**

---

## Step 2: Replace the JavaScript File

1. In the Developer Console, you should see a new tab: `shoppingListManager.cmp`
2. On the **right sidebar**, click the **Controller** button
3. **Delete ALL the existing code**
4. **Copy the entire code below** and paste it:

```javascript
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
        return this.shoppingLists.reduce((sum, list) => sum + list.totalItems, 0);
    }

    get totalCostAcrossLists() {
        const total = this.shoppingLists.reduce((sum, list) => sum + (list.totalCost || 0), 0);
        return total.toFixed(2);
    }

    get totalSavingsAcrossLists() {
        const total = this.shoppingLists.reduce((sum, list) => sum + (list.totalSavings || 0), 0);
        return total.toFixed(2);
    }
}
```

5. **File → Save**
6. Wait for "Compiled successfully" message

---

## WAIT! Important Note

The Developer Console creates **Aura components** (.cmp files), but we need a **Lightning Web Component** (LWC). The process above won't work for LWC.

Since the SF CLI is having issues and Developer Console doesn't support creating LWCs directly, let me provide you with an **easier workaround**:

---

## Alternative: Use VS Code with Salesforce Extension

### Step 1: Install VS Code Extensions (if not already installed)

1. Download and install [Visual Studio Code](https://code.visualstudio.com/)
2. Open VS Code
3. Click **Extensions** icon (left sidebar)
4. Search for: **Salesforce Extension Pack**
5. Click **Install**

### Step 2: Authorize Your Salesforce Org

1. In VS Code, press `Ctrl+Shift+P` (Windows) or `Cmd+Shift+P` (Mac)
2. Type: `SFDX: Authorize an Org`
3. Select **Production**
4. Login with your Salesforce credentials
5. Set an alias: `NeuroThrive`

### Step 3: Deploy the Component

1. In VS Code, navigate to your project folder:
   ```
   C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant
   ```

2. Right-click on the folder:
   ```
   force-app\main\default\lwc\shoppingListManager
   ```

3. Select: **SFDX: Deploy Source to Org**

4. Wait for deployment to complete (should take 10-30 seconds)

5. Check the output panel for success message

---

## Verify Deployment

After deploying via VS Code:

1. Go to **Setup** in Salesforce
2. Search: **Lightning Components**
3. Find: `shoppingListManager`
4. Should show "Last Modified: Today"

---

## Next Steps

Once deployed:

1. Go to a **Weekly Meal Plan** record
2. Click **⚙️** (gear icon) → **Edit Page**
3. Find `shoppingListManager` in the component list (left sidebar)
4. Drag it onto the page
5. Click **Save**
6. Test the shopping list functionality

---

## Troubleshooting

**VS Code not deploying?**
- Make sure you're connected to the internet
- Check that you authorized the correct org
- Try: `Ctrl+Shift+P` → `SFDX: Deploy This Source to Org`

**Component still erroring?**
- Clear browser cache
- Refresh the page
- Check that `ShoppingListController` Apex class exists

**Can't find the component after deployment?**
- Wait 2-3 minutes for metadata to refresh
- Log out and log back into Salesforce
- Check Setup → Lightning Components

---

Let me know which method you'd like to try, or if you need help with any of these steps!
