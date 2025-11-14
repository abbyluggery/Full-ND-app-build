/**
 * @description Test class for CouponMatcher
 */
@isTest
private class CouponMatcherTest {

    @TestSetup
    static void setupTestData() {
        // Create shopping lists for different stores
        List<Shopping_List__c> shoppingLists = new List<Shopping_List__c>();

        shoppingLists.add(new Shopping_List__c(
            Store__c = 'Publix',
            Shopping_Date__c = Date.today(),
            Status__c = 'Draft'
        ));

        shoppingLists.add(new Shopping_List__c(
            Store__c = 'Walmart',
            Shopping_Date__c = Date.today(),
            Status__c = 'Draft'
        ));

        insert shoppingLists;

        // Create shopping list items
        List<Shopping_List_Item__c> items = new List<Shopping_List_Item__c>();

        items.add(new Shopping_List_Item__c(
            Shopping_List__c = shoppingLists[0].Id,
            Item_Name__c = 'Chicken Breast',
            Quantity__c = 2,
            Unit__c = 'lb',
            Store__c = 'Publix',
            Estimated_Price__c = 10.00
        ));

        items.add(new Shopping_List_Item__c(
            Shopping_List__c = shoppingLists[0].Id,
            Item_Name__c = 'Eggs',
            Quantity__c = 1,
            Unit__c = 'dozen',
            Store__c = 'Publix',
            Estimated_Price__c = 4.00
        ));

        items.add(new Shopping_List_Item__c(
            Shopping_List__c = shoppingLists[1].Id,
            Item_Name__c = 'Bread',
            Quantity__c = 1,
            Unit__c = 'loaf',
            Store__c = 'Walmart',
            Estimated_Price__c = 2.50
        ));

        insert items;

        // Create coupons
        List<Store_Coupon__c> coupons = new List<Store_Coupon__c>();

        // BOGO coupon for chicken at Publix
        coupons.add(new Store_Coupon__c(
            Name = 'Publix Chicken BOGO',
            Item_Name__c = 'Chicken',
            Store__c = 'Publix',
            Discount_Type__c = 'BOGO',
            Valid_From__c = Date.today().addDays(-7),
            Valid_To__c = Date.today().addDays(7),
            Source__c = 'Store Ad'
        ));

        // Percentage discount for eggs at Publix
        coupons.add(new Store_Coupon__c(
            Name = 'Publix Eggs 20% Off',
            Item_Name__c = 'Eggs',
            Store__c = 'Publix',
            Discount_Type__c = 'Percentage',
            Discount_Value__c = 20,
            Valid_From__c = Date.today().addDays(-7),
            Valid_To__c = Date.today().addDays(7),
            Source__c = 'Digital Coupon'
        ));

        // Dollar amount coupon for bread at Walmart
        coupons.add(new Store_Coupon__c(
            Name = 'Walmart Bread $0.50 Off',
            Item_Name__c = 'Bread',
            Store__c = 'Walmart',
            Discount_Type__c = 'Dollar Amount',
            Discount_Value__c = 0.50,
            Valid_From__c = Date.today().addDays(-7),
            Valid_To__c = Date.today().addDays(7),
            Source__c = 'Manufacturer Coupon'
        ));

        // Expired coupon (should not match)
        coupons.add(new Store_Coupon__c(
            Name = 'Expired Chicken Coupon',
            Item_Name__c = 'Chicken',
            Store__c = 'Publix',
            Discount_Type__c = 'Dollar Amount',
            Discount_Value__c = 5.00,
            Valid_From__c = Date.today().addDays(-30),
            Valid_To__c = Date.today().addDays(-1),
            Source__c = 'Store Ad'
        ));

        insert coupons;
    }

    @isTest
    static void testMatchCoupons_Success() {
        List<Shopping_List__c> shoppingLists = [SELECT Id FROM Shopping_List__c];

        Test.startTest();
        Integer matchCount = CouponMatcher.matchCoupons(new List<Id>{shoppingLists[0].Id, shoppingLists[1].Id});
        Test.stopTest();

        System.assert(matchCount > 0, 'Should match at least one coupon');

        // Verify items have coupons matched
        List<Shopping_List_Item__c> itemsWithCoupons = [
            SELECT Id, Item_Name__c, Coupon_Available__c, Coupon_Discount__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingLists
            AND Coupon_Available__c = true
        ];

        System.assert(!itemsWithCoupons.isEmpty(), 'Should have items with coupons matched');
    }

    @isTest
    static void testBOGOCoupon() {
        Shopping_List__c publixList = [SELECT Id FROM Shopping_List__c WHERE Store__c = 'Publix' LIMIT 1];

        Test.startTest();
        Integer matchCount = CouponMatcher.matchCoupons(new List<Id>{publixList.Id});
        Test.stopTest();

        // Check chicken item has BOGO coupon (50% savings)
        Shopping_List_Item__c chickenItem = [
            SELECT Coupon_Available__c, Coupon_Discount__c, Estimated_Price__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c = :publixList.Id
            AND Item_Name__c = 'Chicken Breast'
            LIMIT 1
        ];

        System.assertEquals(true, chickenItem.Coupon_Available__c, 'Chicken should have coupon');
        // BOGO = 50% off, so discount should be half the price
        Decimal expectedDiscount = chickenItem.Estimated_Price__c * 0.5;
        System.assertEquals(expectedDiscount, chickenItem.Coupon_Discount__c, 'BOGO should give 50% discount');
    }

    @isTest
    static void testPercentageCoupon() {
        Shopping_List__c publixList = [SELECT Id FROM Shopping_List__c WHERE Store__c = 'Publix' LIMIT 1];

        Test.startTest();
        CouponMatcher.matchCoupons(new List<Id>{publixList.Id});
        Test.stopTest();

        Shopping_List_Item__c eggsItem = [
            SELECT Coupon_Available__c, Coupon_Discount__c, Estimated_Price__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c = :publixList.Id
            AND Item_Name__c = 'Eggs'
            LIMIT 1
        ];

        System.assertEquals(true, eggsItem.Coupon_Available__c, 'Eggs should have coupon');
        // 20% off $4.00 = $0.80
        Decimal expectedDiscount = eggsItem.Estimated_Price__c * 0.20;
        System.assertEquals(expectedDiscount, eggsItem.Coupon_Discount__c, 'Should give 20% discount');
    }

    @isTest
    static void testDollarAmountCoupon() {
        Shopping_List__c walmartList = [SELECT Id FROM Shopping_List__c WHERE Store__c = 'Walmart' LIMIT 1];

        Test.startTest();
        CouponMatcher.matchCoupons(new List<Id>{walmartList.Id});
        Test.stopTest();

        Shopping_List_Item__c breadItem = [
            SELECT Coupon_Available__c, Coupon_Discount__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c = :walmartList.Id
            AND Item_Name__c = 'Bread'
            LIMIT 1
        ];

        System.assertEquals(true, breadItem.Coupon_Available__c, 'Bread should have coupon');
        System.assertEquals(0.50, breadItem.Coupon_Discount__c, 'Should give $0.50 discount');
    }

    @isTest
    static void testExpiredCouponNotMatched() {
        Shopping_List__c publixList = [SELECT Id FROM Shopping_List__c WHERE Store__c = 'Publix' LIMIT 1];

        // Count active coupons for chicken
        Integer activeCoupons = [
            SELECT COUNT()
            FROM Store_Coupon__c
            WHERE Item_Name__c = 'Chicken'
            AND Valid_From__c <= TODAY
            AND Valid_To__c >= TODAY
        ];

        Test.startTest();
        CouponMatcher.matchCoupons(new List<Id>{publixList.Id});
        Test.stopTest();

        // Should only match active coupons, not expired ones
        System.assertEquals(1, activeCoupons, 'Should only have 1 active chicken coupon (expired one excluded)');
    }

    @isTest
    static void testStoreMatching() {
        Shopping_List__c publixList = [SELECT Id FROM Shopping_List__c WHERE Store__c = 'Publix' LIMIT 1];

        Test.startTest();
        CouponMatcher.matchCoupons(new List<Id>{publixList.Id});
        Test.stopTest();

        // Walmart bread coupon should NOT match Publix list
        List<Shopping_List_Item__c> publixItems = [
            SELECT Matched_Coupon__r.Store__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c = :publixList.Id
            AND Coupon_Available__c = true
        ];

        for (Shopping_List_Item__c item : publixItems) {
            System.assertEquals('Publix', item.Matched_Coupon__r.Store__c, 'Should only match Publix coupons to Publix list');
        }
    }

    @isTest
    static void testCalculateTotalSavings() {
        List<Shopping_List__c> shoppingLists = [SELECT Id FROM Shopping_List__c];

        CouponMatcher.matchCoupons(new List<Id>{shoppingLists[0].Id, shoppingLists[1].Id});

        Test.startTest();
        Decimal totalSavings = CouponMatcher.calculateTotalSavings(new List<Id>{shoppingLists[0].Id, shoppingLists[1].Id});
        Test.stopTest();

        System.assert(totalSavings > 0, 'Should have total savings calculated');
        // Chicken BOGO: $5.00 + Eggs 20%: $0.80 + Bread $0.50 = $6.30
        System.assert(totalSavings >= 6.0, 'Total savings should be at least $6.00');
    }

    @isTest
    static void testGetCouponSummary() {
        List<Shopping_List__c> shoppingLists = [SELECT Id FROM Shopping_List__c];

        CouponMatcher.matchCoupons(new List<Id>{shoppingLists[0].Id, shoppingLists[1].Id});

        Test.startTest();
        Map<String, Integer> summary = CouponMatcher.getCouponSummary(new List<Id>{shoppingLists[0].Id, shoppingLists[1].Id});
        Test.stopTest();

        System.assert(!summary.isEmpty(), 'Should have coupon summary');
        System.assert(summary.containsKey('Publix') || summary.containsKey('Walmart'), 'Should have store breakdown');
    }

    @isTest
    static void testEmptyShoppingList() {
        Test.startTest();
        Integer matchCount = CouponMatcher.matchCoupons(new List<Id>());
        Test.stopTest();

        System.assertEquals(0, matchCount, 'Should return 0 for empty list');
    }

    @isTest
    static void testNullInput() {
        Test.startTest();
        Integer matchCount = CouponMatcher.matchCoupons(null);
        Test.stopTest();

        System.assertEquals(0, matchCount, 'Should handle null input gracefully');
    }

    @isTest
    static void testInvocableMethod() {
        List<Shopping_List__c> shoppingLists = [SELECT Id FROM Shopping_List__c LIMIT 1];

        CouponMatcher.CouponMatchRequest request = new CouponMatcher.CouponMatchRequest();
        request.shoppingListIds = new List<Id>{shoppingLists[0].Id};

        Test.startTest();
        List<CouponMatcher.CouponMatchResult> results =
            CouponMatcher.matchCouponsFromFlow(new List<CouponMatcher.CouponMatchRequest>{request});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].success, 'Should be successful');
        System.assert(results[0].itemsWithCoupons > 0, 'Should have matched coupons');
        System.assert(results[0].totalSavings > 0, 'Should have calculated savings');
    }

    @isTest
    static void testPartialItemMatch() {
        // Create item with partial name match
        Shopping_List__c shoppingList = [SELECT Id FROM Shopping_List__c WHERE Store__c = 'Publix' LIMIT 1];

        Shopping_List_Item__c item = new Shopping_List_Item__c(
            Shopping_List__c = shoppingList.Id,
            Item_Name__c = 'Organic Free Range Chicken Breast',
            Quantity__c = 1,
            Unit__c = 'lb',
            Store__c = 'Publix',
            Estimated_Price__c = 12.00
        );
        insert item;

        Test.startTest();
        CouponMatcher.matchCoupons(new List<Id>{shoppingList.Id});
        Test.stopTest();

        item = [SELECT Coupon_Available__c FROM Shopping_List_Item__c WHERE Id = :item.Id];
        System.assertEquals(true, item.Coupon_Available__c, 'Should match coupon with partial name match');
    }
}
