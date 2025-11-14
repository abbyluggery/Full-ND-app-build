# Manual shoppingListManager Component Deployment

Since the Salesforce CLI is having issues, here's the **easiest manual method** using Workbench.

---

## What We're Fixing

The component has a JavaScript error:
```
s.reduce(...).toFixed is not a function
```

**Root cause:** The `calculateTotal()` and `calculateSavings()` methods were returning STRINGS (from `.toFixed(2)`), but later code was trying to do math on them.

**Fix:** Return numbers from calculation methods, only format to strings in the display getters.

---

## Deployment Method: Workbench (Recommended)

### Step 1: Open Workbench

1. Go to: [https://workbench.developerforce.com/](https://workbench.developerforce.com/)
2. Click **Login with Salesforce**
3. Select **Production** environment
4. Check **I agree to the terms of service**
5. Click **Login**

### Step 2: Prepare to Deploy

Since Workbench requires a ZIP file with proper structure, I've created an easier approach:

**Use the Developer Console copy-paste method instead** (see below).

---

## EASIEST METHOD: Developer Console

The SF CLI has a bug with the metadata translation. Let's use the Developer Console's text editor to manually update the JavaScript file.

### Step 1: Open the Existing Component

1. **Open Salesforce** → Click **⚙️** → **Developer Console**
2. **File → Open Lightning Resources**
3. **Type:** `shopping` in the search box

**If you DON'T see `shoppingListManager`:**
- The component may not exist in your org yet
- We'll need to deploy it fresh using VS Code (see next section)

**If you DO see it:**
1. Click on `shoppingListManager`
2. Select the **JavaScript file** from the list
3. Click **Open Selected**

### Step 2: Replace the JavaScript Code

1. In the code editor, **select ALL the code** (Ctrl+A)
2. **Delete it**
3. **Paste the following fixed code:**

```javascript
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getShoppingLists from '@salesforce/apex/ShoppingListController.getShoppingLists';
import toggleItemPurchased from '@salesforce/apex/ShoppingListController.toggleItemPurchased';
import generateShoppingLists from '@salesforce/apex/ShoppingListController.generateShoppingLists';
import matchCoupons from '@salesforce/apex/ShoppingListController.matchCoupons';

export default class ShoppingListManager extends LightningElement {
    @api recordId;
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

4. **File → Save**
5. Wait for "Compiled successfully" message

### Step 3: Test the Fix

1. Go to any **Weekly Meal Plan** record
2. The shopping list should now load without errors
3. The totals should calculate correctly

---

## IF Component Doesn't Exist: VS Code Method

If the component doesn't show up in Developer Console, you'll need to deploy it fresh using VS Code.

### Option A: Use VS Code Command Line

1. Open **Command Prompt**
2. Navigate to your project:
   ```
   cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"
   ```

3. Deploy the component:
   ```
   "C:\Program Files\sf\bin\sf.cmd" project deploy start --source-dir force-app/main/default/lwc/shoppingListManager --target-org abbyluggery179@agentforce.com --wait 15 --ignore-errors
   ```

### Option B: Use VS Code GUI

1. Open VS Code
2. **File → Open Folder** → Navigate to:
   ```
   C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant
   ```

3. In the left sidebar (Explorer), navigate to:
   ```
   force-app → main → default → lwc → shoppingListManager
   ```

4. **Right-click** on the `shoppingListManager` folder
5. Select **SFDX: Deploy Source to Org**
6. Wait for deployment confirmation

---

## Verification

After deployment:

1. **Setup → Lightning Components**
2. Search: `shoppingListManager`
3. Should show "Last Modified: Today"

Then test:

1. Go to a **Weekly Meal Plan** record
2. Component should load without the `.toFixed()` error
3. Shopping lists should display correctly

---

## What Changed (Technical Details)

### Before (Broken):
```javascript
calculateTotal(items) {
    return items.reduce((sum, item) => {
        return sum + (item.estimatedPrice || 0);
    }, 0).toFixed(2);  // Returns STRING "15.50"
}

get totalCostAcrossLists() {
    return this.shoppingLists.reduce((sum, list) => sum + parseFloat(list.totalCost), 0).toFixed(2);
    // Tries to do: "15.50" + parseFloat("10.00") = error
}
```

### After (Fixed):
```javascript
calculateTotal(items) {
    return items.reduce((sum, item) => {
        return sum + (item.estimatedPrice || 0);
    }, 0);  // Returns NUMBER 15.50
}

get totalCostAcrossLists() {
    const total = this.shoppingLists.reduce((sum, list) => sum + (list.totalCost || 0), 0);
    return total.toFixed(2);  // Calculate first, then format
}
```

**Key fix:** Separate number calculations from string formatting.

---

## Need Help?

If you're still stuck, let me know:

1. Which method did you try?
2. Did the component show up in Developer Console?
3. What error message (if any) did you get?

I can help troubleshoot from there!
