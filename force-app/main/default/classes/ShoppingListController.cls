/**
 * @description Controller for ShoppingListManager Lightning Web Component
 * - Retrieves shopping lists with items and coupon info
 * - Handles item purchase toggles
 * - Integrates with ShoppingListGenerator and CouponMatcher
 */
public with sharing class ShoppingListController {

    /**
     * @description Gets all shopping lists for a meal plan with items
     * @param mealPlanId The Weekly_Meal_Plan__c record ID
     * @return List of shopping list data with items
     */
    @AuraEnabled(cacheable=true)
    public static List<ShoppingListData> getShoppingLists(Id mealPlanId) {
        try {
            List<Shopping_List__c> lists = [
                SELECT Id, Name, Store__c, Shopping_Date__c, Status__c,
                       Weekly_Meal_Plan__c,
                       (SELECT Id, Item_Name__c, Quantity__c, Unit__c, Category__c,
                               Estimated_Price__c, Is_Purchased__c, Coupon_Available__c,
                               Coupon_Discount__c
                        FROM Shopping_List_Items__r
                        ORDER BY Category__c, Item_Name__c)
                FROM Shopping_List__c
                WHERE Weekly_Meal_Plan__c = :mealPlanId
                ORDER BY Store__c
            ];

            List<ShoppingListData> result = new List<ShoppingListData>();

            for (Shopping_List__c shoppingList : lists) {
                ShoppingListData data = new ShoppingListData();
                data.id = shoppingList.Id;
                data.name = shoppingList.Name;
                data.store = shoppingList.Store__c;
                data.shoppingDate = shoppingList.Shopping_Date__c != null ?
                                   shoppingList.Shopping_Date__c.format() : '';
                data.status = shoppingList.Status__c;

                data.items = new List<ShoppingItemData>();
                for (Shopping_List_Item__c item : shoppingList.Shopping_List_Items__r) {
                    ShoppingItemData itemData = new ShoppingItemData();
                    itemData.id = item.Id;
                    itemData.name = item.Item_Name__c;
                    itemData.quantity = item.Quantity__c;
                    itemData.unit = item.Unit__c;
                    itemData.category = item.Category__c != null ? item.Category__c : 'Other';
                    itemData.estimatedPrice = item.Estimated_Price__c != null ?
                                             item.Estimated_Price__c : 0;
                    itemData.isPurchased = item.Is_Purchased__c != null ?
                                          item.Is_Purchased__c : false;
                    itemData.hasCoupon = item.Coupon_Available__c != null ?
                                        item.Coupon_Available__c : false;
                    itemData.couponDiscount = item.Coupon_Discount__c != null ?
                                             item.Coupon_Discount__c : 0;
                    itemData.finalPrice = itemData.estimatedPrice - itemData.couponDiscount;

                    data.items.add(itemData);
                }

                result.add(data);
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading shopping lists: ' + e.getMessage());
        }
    }

    /**
     * @description Toggles the purchased status of a shopping list item
     * @param itemId The Shopping_List_Item__c record ID
     * @return Updated item
     */
    @AuraEnabled
    public static Shopping_List_Item__c toggleItemPurchased(Id itemId) {
        try {
            Shopping_List_Item__c item = [
                SELECT Id, Is_Purchased__c
                FROM Shopping_List_Item__c
                WHERE Id = :itemId
                LIMIT 1
            ];

            item.Is_Purchased__c = !item.Is_Purchased__c;
            update item;

            return item;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating item: ' + e.getMessage());
        }
    }

    /**
     * @description Generates shopping lists for a meal plan
     * @param mealPlanId The Weekly_Meal_Plan__c record ID
     * @return List of created shopping list IDs
     */
    @AuraEnabled
    public static List<Id> generateShoppingLists(Id mealPlanId) {
        try {
            return ShoppingListGenerator.generateShoppingLists(mealPlanId);
        } catch (Exception e) {
            throw new AuraHandledException('Error generating shopping lists: ' + e.getMessage());
        }
    }

    /**
     * @description Matches coupons to shopping list items
     * @param shoppingListIds List of Shopping_List__c IDs
     * @return Result with match count and savings
     */
    @AuraEnabled
    public static CouponMatchResult matchCoupons(List<Id> shoppingListIds) {
        try {
            Integer matchCount = CouponMatcher.matchCoupons(shoppingListIds);
            Decimal totalSavings = CouponMatcher.calculateTotalSavings(shoppingListIds);

            CouponMatchResult result = new CouponMatchResult();
            result.itemsWithCoupons = matchCount;
            result.totalSavings = totalSavings;

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error matching coupons: ' + e.getMessage());
        }
    }

    // Wrapper classes

    public class ShoppingListData {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String store;
        @AuraEnabled public String shoppingDate;
        @AuraEnabled public String status;
        @AuraEnabled public List<ShoppingItemData> items;
    }

    public class ShoppingItemData {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public String unit;
        @AuraEnabled public String category;
        @AuraEnabled public Decimal estimatedPrice;
        @AuraEnabled public Boolean isPurchased;
        @AuraEnabled public Boolean hasCoupon;
        @AuraEnabled public Decimal couponDiscount;
        @AuraEnabled public Decimal finalPrice;
    }

    public class CouponMatchResult {
        @AuraEnabled public Integer itemsWithCoupons;
        @AuraEnabled public Decimal totalSavings;
    }
}
