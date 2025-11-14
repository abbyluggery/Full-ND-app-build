/**
 * @description Test class for ShoppingListController
 */
@isTest
private class ShoppingListControllerTest {

    @testSetup
    static void setupTestData() {
        // Create meal plan
        Weekly_Meal_Plan__c mealPlan = new Weekly_Meal_Plan__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(13),
            Week_Start_Date__c = Date.today(),
            Week_End_Date__c = Date.today().addDays(13),
            Number_of_People__c = 5,
            Status__c = 'Active'
        );
        insert mealPlan;

        // Create shopping lists
        List<Shopping_List__c> lists = new List<Shopping_List__c>();
        lists.add(new Shopping_List__c(
            Weekly_Meal_Plan__c = mealPlan.Id,
            Store__c = 'Publix',
            Shopping_Date__c = Date.today(),
            Status__c = 'Draft'
        ));
        lists.add(new Shopping_List__c(
            Weekly_Meal_Plan__c = mealPlan.Id,
            Store__c = 'Walmart',
            Shopping_Date__c = Date.today(),
            Status__c = 'Draft'
        ));
        insert lists;

        // Create shopping list items
        List<Shopping_List_Item__c> items = new List<Shopping_List_Item__c>();
        items.add(new Shopping_List_Item__c(
            Shopping_List__c = lists[0].Id,
            Item_Name__c = 'Chicken Breast',
            Quantity__c = 2,
            Unit__c = 'lb',
            Category__c = 'Meat & Seafood',
            Estimated_Price__c = 12.99,
            Is_Purchased__c = false
        ));
        items.add(new Shopping_List_Item__c(
            Shopping_List__c = lists[0].Id,
            Item_Name__c = 'Eggs',
            Quantity__c = 1,
            Unit__c = 'dozen',
            Category__c = 'Dairy',
            Estimated_Price__c = 3.99,
            Is_Purchased__c = false,
            Coupon_Available__c = true,
            Coupon_Discount__c = 0.50
        ));
        insert items;
    }

    @isTest
    static void testGetShoppingLists_Success() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<ShoppingListController.ShoppingListData> result =
            ShoppingListController.getShoppingLists(mealPlan.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.size(), 'Should have 2 shopping lists');

        ShoppingListController.ShoppingListData publix = result[0];
        System.assertEquals('Publix', publix.store, 'First list should be Publix');
        System.assertEquals(2, publix.items.size(), 'Publix list should have 2 items');

        // Verify item data
        ShoppingListController.ShoppingItemData item = publix.items[1]; // Eggs
        System.assertEquals('Eggs', item.name, 'Item name should be Eggs');
        System.assertEquals(true, item.hasCoupon, 'Should have coupon');
        System.assertEquals(0.50, item.couponDiscount, 'Discount should be 0.50');
        System.assertEquals(3.49, item.finalPrice, 'Final price should be discounted');
    }

    @isTest
    static void testToggleItemPurchased_Success() {
        Shopping_List_Item__c item = [
            SELECT Id, Is_Purchased__c
            FROM Shopping_List_Item__c
            WHERE Item_Name__c = 'Chicken Breast'
            LIMIT 1
        ];

        System.assertEquals(false, item.Is_Purchased__c, 'Should start as not purchased');

        Test.startTest();
        Shopping_List_Item__c updated = ShoppingListController.toggleItemPurchased(item.Id);
        Test.stopTest();

        System.assertEquals(true, updated.Is_Purchased__c, 'Should be marked as purchased');

        // Toggle back
        updated = ShoppingListController.toggleItemPurchased(item.Id);
        System.assertEquals(false, updated.Is_Purchased__c, 'Should be unmarked');
    }

    @isTest
    static void testGetShoppingLists_InvalidId() {
        Id invalidId = Id.valueOf('a00000000000000AAA');

        Test.startTest();
        try {
            ShoppingListController.getShoppingLists(invalidId);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error loading shopping lists'),
                         'Should contain error message');
        }
        Test.stopTest();
    }

    @isTest
    static void testToggleItemPurchased_InvalidId() {
        Id invalidId = Id.valueOf('a02000000000000AAA');

        Test.startTest();
        try {
            ShoppingListController.toggleItemPurchased(invalidId);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error updating item'),
                         'Should contain error message');
        }
        Test.stopTest();
    }

    @isTest
    static void testWrapperClasses() {
        Test.startTest();

        ShoppingListController.ShoppingListData listData = new ShoppingListController.ShoppingListData();
        listData.id = Id.valueOf('a01000000000000AAA');
        listData.name = 'Test List';
        listData.store = 'Publix';

        ShoppingListController.ShoppingItemData itemData = new ShoppingListController.ShoppingItemData();
        itemData.id = Id.valueOf('a02000000000000AAA');
        itemData.name = 'Test Item';
        itemData.quantity = 2;

        ShoppingListController.CouponMatchResult result = new ShoppingListController.CouponMatchResult();
        result.itemsWithCoupons = 5;
        result.totalSavings = 10.50;

        Test.stopTest();

        System.assertNotEquals(null, listData, 'ListData should not be null');
        System.assertNotEquals(null, itemData, 'ItemData should not be null');
        System.assertNotEquals(null, result, 'Result should not be null');
    }
}
