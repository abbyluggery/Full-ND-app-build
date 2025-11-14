/**
 * @description Service class for Walgreens API integration
 * - Fetches digital coupons and offers
 * - Handles API authentication via OAuth2
 * - Parses and structures response data
 */
public with sharing class WalgreensAPIService {

    private static final String BASE_URL = 'https://services-qa.walgreens.com/api';
    private static final String OFFERS_ENDPOINT = '/offers/v1/digital-coupons';

    /**
     * @description Fetches digital coupons from Walgreens API
     * @param limit Maximum number of coupons to fetch (default: 100)
     * @return List of coupon data maps
     */
    public static List<Map<String, Object>> fetchDigitalCoupons(Integer offerLimit) {
        String accessToken = WalgreensOAuthHandler.getAccessToken();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + OFFERS_ENDPOINT + '?limit=' + offerLimit);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(30000); // 30 second timeout

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> offers = (List<Object>) responseBody.get('offers');

            List<Map<String, Object>> coupons = new List<Map<String, Object>>();
            for (Object offer : offers) {
                coupons.add((Map<String, Object>) offer);
            }

            return coupons;
        } else if (res.getStatusCode() == 401) {
            // Unauthorized - token expired, force refresh and retry
            WalgreensOAuthHandler.forceTokenRefresh();
            return fetchDigitalCoupons(offerLimit); // Recursive retry
        } else {
            throw new WalgreensAPIException('Failed to fetch coupons: ' + res.getStatus() + ' - ' + res.getBody());
        }
    }

    /**
     * @description Parses Walgreens coupon data into Store_Coupon__c records
     * @param couponsData Raw API response data
     * @return List of Store_Coupon__c records (not yet inserted)
     */
    public static List<Store_Coupon__c> parseCoupons(List<Map<String, Object>> couponsData) {
        List<Store_Coupon__c> coupons = new List<Store_Coupon__c>();

        for (Map<String, Object> couponData : couponsData) {
            Store_Coupon__c coupon = new Store_Coupon__c();

            // External ID for de-duplication
            coupon.External_Coupon_ID__c = (String) couponData.get('offerId');

            // Basic info
            coupon.Item_Name__c = (String) couponData.get('title');
            coupon.Store__c = 'Walgreens';
            coupon.Source__c = 'Walgreens API';
            coupon.API_Source__c = 'Walgreens Digital Coupons API';

            // Discount info
            String discountType = (String) couponData.get('discountType'); // e.g., "PERCENTAGE", "FIXED"
            Decimal discountValue = (Decimal) couponData.get('discountValue');

            if (discountType == 'PERCENTAGE') {
                coupon.Discount_Type__c = 'Percentage';
                coupon.Discount_Value__c = discountValue;
            } else if (discountType == 'FIXED') {
                coupon.Discount_Type__c = 'Dollar Amount';
                coupon.Discount_Value__c = discountValue;
            }

            // Validity dates
            String validFrom = (String) couponData.get('validFrom');
            String validTo = (String) couponData.get('validTo');

            if (String.isNotBlank(validFrom)) {
                coupon.Valid_From__c = Date.valueOf(validFrom.substring(0, 10)); // Parse ISO date
            }
            if (String.isNotBlank(validTo)) {
                coupon.Valid_To__c = Date.valueOf(validTo.substring(0, 10));
            }

            // Clip URL and account requirements
            coupon.Clip_URL__c = (String) couponData.get('clipUrl');
            coupon.Requires_Account__c = true; // Walgreens digital coupons require Balance Rewards
            coupon.Account_Type__c = 'Walgreens Balance Rewards';

            // Metadata
            coupon.Last_Synced__c = DateTime.now();
            coupon.Is_Stackable__c = false; // Walgreens typically doesn't stack digital coupons

            // Product category (optional, may not be in API response)
            String category = (String) couponData.get('category');
            if (String.isNotBlank(category)) {
                coupon.Applicable_Product_Category__c = category;
            }

            // Description/notes
            String description = (String) couponData.get('description');
            if (String.isNotBlank(description)) {
                coupon.Notes__c = description;
            }

            coupons.add(coupon);
        }

        return coupons;
    }

    /**
     * @description Upserts coupons using External_Coupon_ID__c to avoid duplicates
     * @param coupons List of Store_Coupon__c records to upsert
     * @return Database.UpsertResult list
     */
    public static List<Database.UpsertResult> upsertCoupons(List<Store_Coupon__c> coupons) {
        return Database.upsert(coupons, Store_Coupon__c.External_Coupon_ID__c, false);
    }

    /**
     * @description Custom exception for API errors
     */
    public class WalgreensAPIException extends Exception {}
}
