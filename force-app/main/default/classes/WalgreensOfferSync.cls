/**
 * @description Batch job to sync Walgreens digital coupons on a schedule
 * - Fetches latest coupons from Walgreens API
 * - Upserts to Store_Coupon__c object
 * - Handles errors gracefully
 */
public class WalgreensOfferSync implements Database.Batchable<Map<String, Object>>, Database.AllowsCallouts {

    private List<Map<String, Object>> couponsData;
    private Integer fetchLimit;

    /**
     * @description Constructor with custom fetch limit
     * @param offerLimit Maximum number of coupons to fetch
     */
    public WalgreensOfferSync(Integer offerLimit) {
        this.fetchLimit = offerLimit != null ? offerLimit : 100;
    }

    /**
     * @description Default constructor (fetches 100 coupons)
     */
    public WalgreensOfferSync() {
        this(100);
    }

    /**
     * @description Start method - fetches coupons from API
     * @param bc BatchableContext
     * @return Iterable of coupon data maps
     */
    public Iterable<Map<String, Object>> start(Database.BatchableContext bc) {
        try {
            couponsData = WalgreensAPIService.fetchDigitalCoupons(fetchLimit);
            return couponsData;
        } catch (Exception e) {
            // Log error and return empty list to prevent batch failure
            System.debug(LoggingLevel.ERROR, 'Failed to fetch Walgreens coupons: ' + e.getMessage());
            return new List<Map<String, Object>>();
        }
    }

    /**
     * @description Execute method - processes coupons in batches
     * @param bc BatchableContext
     * @param scope Batch of coupon data
     */
    public void execute(Database.BatchableContext bc, List<Map<String, Object>> scope) {
        try {
            List<Store_Coupon__c> coupons = WalgreensAPIService.parseCoupons(scope);
            List<Database.UpsertResult> results = WalgreensAPIService.upsertCoupons(coupons);

            // Log any failures
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug(LoggingLevel.ERROR, 'Failed to upsert coupon: ' +
                                coupons[i].External_Coupon_ID__c + ' - ' +
                                results[i].getErrors());
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing coupon batch: ' + e.getMessage());
        }
    }

    /**
     * @description Finish method - logs completion
     * @param bc BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Walgreens coupon sync completed. Fetched ' +
                    (couponsData != null ? couponsData.size() : 0) + ' coupons.');

        // Update sync timestamp in Custom Settings
        Walgreens_API_Settings__c settings = Walgreens_API_Settings__c.getOrgDefaults();
        if (settings != null) {
            settings.Last_Sync_Date__c = DateTime.now();
            update settings;
        }
    }
}
