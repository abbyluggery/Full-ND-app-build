/**
 * Test Coupon Matching
 *
 * This script:
 * 1. Queries existing shopping lists
 * 2. Runs the coupon matcher
 * 3. Shows results with matched coupons and savings
 *
 * Run in Developer Console Anonymous Apex
 */

System.debug('========== COUPON MATCHING TEST ==========');

// Get all shopping lists
List<Shopping_List__c> shoppingLists = [
    SELECT Id, Name, Store__c, Shopping_Date__c,
           (SELECT Id, Item_Name__c, Quantity__c, Estimated_Price__c,
                   Coupon_Available__c, Coupon_Discount__c
            FROM Shopping_List_Items__r)
    FROM Shopping_List__c
    ORDER BY CreatedDate DESC
    LIMIT 5
];

if (shoppingLists.isEmpty()) {
    System.debug('No shopping lists found. Please create a meal plan and generate shopping lists first.');
} else {
    System.debug('Found ' + shoppingLists.size() + ' shopping list(s)');
    System.debug('');

    // Show shopping lists before matching
    for (Shopping_List__c sl : shoppingLists) {
        System.debug('Shopping List: ' + sl.Name + ' (Store: ' + sl.Store__c + ')');
        System.debug('  Items: ' + sl.Shopping_List_Items__r.size());
    }

    System.debug('');
    System.debug('========== RUNNING COUPON MATCHER ==========');

    // Get list IDs
    List<Id> shoppingListIds = new List<Id>();
    for (Shopping_List__c sl : shoppingLists) {
        shoppingListIds.add(sl.Id);
    }

    // Check how many coupons are available
    Integer totalCoupons = [SELECT COUNT() FROM Store_Coupon__c WHERE Valid_From__c <= TODAY AND Valid_To__c >= TODAY];
    System.debug('Available coupons in system: ' + totalCoupons);
    System.debug('');

    // Run coupon matcher
    Integer matchCount = CouponMatcher.matchCoupons(shoppingListIds);
    Decimal totalSavings = CouponMatcher.calculateTotalSavings(shoppingListIds);

    System.debug('========== RESULTS ==========');
    System.debug('Items with matched coupons: ' + matchCount);
    System.debug('Total potential savings: $' + totalSavings.setScale(2));
    System.debug('');

    // Show detailed results
    List<Shopping_List_Item__c> itemsWithCoupons = [
        SELECT Id, Item_Name__c, Quantity__c, Estimated_Price__c,
               Coupon_Available__c, Coupon_Discount__c,
               Shopping_List__r.Name, Shopping_List__r.Store__c,
               Matched_Coupon__r.Item_Name__c,
               Matched_Coupon__r.Discount_Type__c,
               Matched_Coupon__r.Discount_Value__c
        FROM Shopping_List_Item__c
        WHERE Shopping_List__c IN :shoppingListIds
        AND Coupon_Available__c = true
        ORDER BY Shopping_List__r.Name, Item_Name__c
    ];

    if (itemsWithCoupons.isEmpty()) {
        System.debug('No coupon matches found.');
        System.debug('');
        System.debug('Troubleshooting:');
        System.debug('1. Make sure Store_Coupon__c records exist with valid dates');
        System.debug('2. Check that coupon Item_Name__c matches shopping list item names');
        System.debug('3. Verify coupon Store__c matches shopping list Store__c');
    } else {
        System.debug('========== MATCHED COUPONS DETAIL ==========');

        String currentList = '';
        for (Shopping_List_Item__c item : itemsWithCoupons) {
            if (currentList != item.Shopping_List__r.Name) {
                currentList = item.Shopping_List__r.Name;
                System.debug('');
                System.debug('--- ' + currentList + ' (' + item.Shopping_List__r.Store__c + ') ---');
            }

            String couponInfo = item.Matched_Coupon__r.Item_Name__c +
                              ' (' + item.Matched_Coupon__r.Discount_Type__c + ')';

            System.debug('  ' + item.Item_Name__c);
            System.debug('    Qty: ' + item.Quantity__c +
                        ' | Est Price: $' + (item.Estimated_Price__c != null ? item.Estimated_Price__c.setScale(2) : '0.00') +
                        ' | Savings: $' + (item.Coupon_Discount__c != null ? item.Coupon_Discount__c.setScale(2) : '0.00'));
            System.debug('    Coupon: ' + couponInfo);
        }
    }

    System.debug('');
    System.debug('========== SUMMARY BY STORE ==========');
    Map<String, Integer> summary = CouponMatcher.getCouponSummary(shoppingListIds);
    for (String store : summary.keySet()) {
        System.debug(store + ': ' + summary.get(store) + ' items with coupons');
    }
}

System.debug('');
System.debug('========== TEST COMPLETE ==========');
