/**
 * @description Matches available coupons to shopping list items
 * - Finds valid coupons from Store_Coupon__c for shopping list items
 * - Prioritizes best savings (BOGO, highest discounts)
 * - Validates coupon date ranges and store matching
 * - Handles stackable coupons
 */
public with sharing class CouponMatcher {

    /**
     * @description Matches coupons to all items in shopping lists
     * @param shoppingListIds List of Shopping_List__c IDs
     * @return Number of items with coupons matched
     */
    public static Integer matchCoupons(List<Id> shoppingListIds) {
        if (shoppingListIds == null || shoppingListIds.isEmpty()) {
            return 0;
        }

        // Get shopping lists with their items
        Map<Id, Shopping_List__c> shoppingLists = new Map<Id, Shopping_List__c>([
            SELECT Id, Store__c, Shopping_Date__c
            FROM Shopping_List__c
            WHERE Id IN :shoppingListIds
        ]);

        List<Shopping_List_Item__c> items = [
            SELECT Id, Item_Name__c, Shopping_List__c, Shopping_List__r.Store__c,
                   Shopping_List__r.Shopping_Date__c, Quantity__c, Estimated_Price__c,
                   Coupon_Available__c, Coupon_Discount__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingListIds
        ];

        if (items.isEmpty()) {
            return 0;
        }

        // Get valid coupons for today and future
        Date today = Date.today();
        List<Store_Coupon__c> allCoupons = [
            SELECT Id, Item_Name__c, Store__c, Discount_Type__c, Discount_Value__c,
                   Valid_From__c, Valid_To__c, Is_Stackable__c
            FROM Store_Coupon__c
            WHERE Valid_From__c <= :today
            AND Valid_To__c >= :today
            ORDER BY Discount_Type__c, Discount_Value__c DESC
        ];

        // Match coupons to items
        Integer matchCount = 0;
        List<Shopping_List_Item__c> itemsToUpdate = new List<Shopping_List_Item__c>();

        for (Shopping_List_Item__c item : items) {
            CouponMatch bestMatch = findBestCoupon(item, allCoupons);

            if (bestMatch != null) {
                item.Coupon_Available__c = true;
                item.Coupon_Discount__c = bestMatch.discountAmount;
                item.Matched_Coupon__c = bestMatch.couponId;
                itemsToUpdate.add(item);
                matchCount++;
            }
        }

        if (!itemsToUpdate.isEmpty()) {
            update itemsToUpdate;
        }

        return matchCount;
    }

    /**
     * @description Finds best coupon match for a shopping list item
     */
    private static CouponMatch findBestCoupon(
        Shopping_List_Item__c item,
        List<Store_Coupon__c> availableCoupons
    ) {
        CouponMatch bestMatch = null;
        Decimal bestSavings = 0;

        for (Store_Coupon__c coupon : availableCoupons) {
            // Check if coupon matches item
            if (!isCouponValidForItem(coupon, item)) {
                continue;
            }

            // Calculate savings
            Decimal savings = calculateSavings(coupon, item);

            if (savings > bestSavings) {
                bestSavings = savings;
                bestMatch = new CouponMatch();
                bestMatch.couponId = coupon.Id;
                bestMatch.discountAmount = savings;
            }
        }

        return bestMatch;
    }

    /**
     * @description Validates if coupon can be applied to item
     */
    private static Boolean isCouponValidForItem(Store_Coupon__c coupon, Shopping_List_Item__c item) {
        // Check store match
        if (coupon.Store__c != item.Shopping_List__r.Store__c) {
            return false;
        }

        // Check item name match (case-insensitive, partial match)
        String couponItem = coupon.Item_Name__c != null ? coupon.Item_Name__c.toLowerCase() : '';
        String listItem = item.Item_Name__c != null ? item.Item_Name__c.toLowerCase() : '';

        if (String.isBlank(couponItem) || String.isBlank(listItem)) {
            return false;
        }

        // Match if coupon item is contained in list item or vice versa
        return listItem.contains(couponItem) || couponItem.contains(listItem);
    }

    /**
     * @description Calculates savings from coupon
     */
    private static Decimal calculateSavings(Store_Coupon__c coupon, Shopping_List_Item__c item) {
        Decimal itemPrice = item.Estimated_Price__c != null ? item.Estimated_Price__c : 0;

        if (coupon.Discount_Type__c == 'BOGO') {
            // Buy one get one free - 50% savings
            return itemPrice * 0.5;
        } else if (coupon.Discount_Type__c == 'Percentage') {
            Decimal discountPercent = coupon.Discount_Value__c != null ? coupon.Discount_Value__c : 0;
            return itemPrice * (discountPercent / 100);
        } else if (coupon.Discount_Type__c == 'Dollar Amount') {
            return coupon.Discount_Value__c != null ? coupon.Discount_Value__c : 0;
        } else if (coupon.Discount_Type__c == 'Fixed Price') {
            Decimal fixedPrice = coupon.Discount_Value__c != null ? coupon.Discount_Value__c : 0;
            return itemPrice > fixedPrice ? (itemPrice - fixedPrice) : 0;
        }

        return 0;
    }

    /**
     * @description Calculates total potential savings for shopping lists
     * @param shoppingListIds List of Shopping_List__c IDs
     * @return Total potential savings amount
     */
    public static Decimal calculateTotalSavings(List<Id> shoppingListIds) {
        List<Shopping_List_Item__c> items = [
            SELECT Coupon_Discount__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingListIds
            AND Coupon_Available__c = true
        ];

        Decimal totalSavings = 0;
        for (Shopping_List_Item__c item : items) {
            if (item.Coupon_Discount__c != null) {
                totalSavings += item.Coupon_Discount__c;
            }
        }

        return totalSavings;
    }

    /**
     * @description Gets coupon summary for shopping lists
     * @param shoppingListIds List of Shopping_List__c IDs
     * @return Map of store to coupon count
     */
    public static Map<String, Integer> getCouponSummary(List<Id> shoppingListIds) {
        List<Shopping_List__c> shoppingLists = [
            SELECT Id, Store__c,
                   (SELECT Id FROM Shopping_List_Items__r WHERE Coupon_Available__c = true)
            FROM Shopping_List__c
            WHERE Id IN :shoppingListIds
        ];

        Map<String, Integer> summary = new Map<String, Integer>();

        for (Shopping_List__c sl : shoppingLists) {
            String store = sl.Store__c != null ? sl.Store__c : 'Unknown';
            Integer count = sl.Shopping_List_Items__r.size();

            if (summary.containsKey(store)) {
                summary.put(store, summary.get(store) + count);
            } else {
                summary.put(store, count);
            }
        }

        return summary;
    }

    /**
     * @description Invocable method for Flow integration
     */
    @InvocableMethod(label='Match Coupons to Shopping Lists' description='Finds and applies available coupons to shopping list items')
    public static List<CouponMatchResult> matchCouponsFromFlow(List<CouponMatchRequest> requests) {
        List<CouponMatchResult> results = new List<CouponMatchResult>();

        for (CouponMatchRequest request : requests) {
            Integer matchCount = matchCoupons(request.shoppingListIds);
            Decimal totalSavings = calculateTotalSavings(request.shoppingListIds);

            CouponMatchResult result = new CouponMatchResult();
            result.itemsWithCoupons = matchCount;
            result.totalSavings = totalSavings;
            result.success = true;
            results.add(result);
        }

        return results;
    }

    /**
     * @description Inner class for coupon match result
     */
    private class CouponMatch {
        public Id couponId;
        public Decimal discountAmount;
    }

    /**
     * @description Input wrapper for Flow invocable method
     */
    public class CouponMatchRequest {
        @InvocableVariable(label='Shopping List IDs' description='IDs of shopping lists to match coupons for' required=true)
        public List<Id> shoppingListIds;
    }

    /**
     * @description Output wrapper for Flow invocable method
     */
    public class CouponMatchResult {
        @InvocableVariable(label='Items with Coupons')
        public Integer itemsWithCoupons;

        @InvocableVariable(label='Total Savings')
        public Decimal totalSavings;

        @InvocableVariable(label='Success')
        public Boolean success;
    }
}
