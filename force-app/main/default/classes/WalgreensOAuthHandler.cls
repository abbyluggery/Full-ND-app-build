/**
 * @description Handles OAuth2 authentication for Walgreens API
 * - Manages access token generation and refresh
 * - Stores credentials securely in Custom Settings
 */
public with sharing class WalgreensOAuthHandler {

    private static final String TOKEN_ENDPOINT = 'https://services-qa.walgreens.com/api/oauth/token';
    private static final String GRANT_TYPE = 'client_credentials';

    /**
     * @description Gets a valid access token (from cache or new request)
     * @return OAuth access token
     */
    public static String getAccessToken() {
        // Check for cached token in Custom Settings
        Walgreens_API_Settings__c settings = Walgreens_API_Settings__c.getOrgDefaults();

        if (settings != null &&
            settings.Access_Token__c != null &&
            settings.Token_Expires_At__c != null &&
            settings.Token_Expires_At__c > DateTime.now()) {
            // Return cached valid token
            return settings.Access_Token__c;
        }

        // Request new token
        return requestNewToken();
    }

    /**
     * @description Requests a new access token from Walgreens OAuth endpoint
     * @return New OAuth access token
     */
    private static String requestNewToken() {
        Walgreens_API_Settings__c settings = Walgreens_API_Settings__c.getOrgDefaults();

        if (settings == null ||
            String.isBlank(settings.Client_ID__c) ||
            String.isBlank(settings.Client_Secret__c)) {
            throw new WalgreensAPIException('Walgreens API credentials not configured. Please set up Walgreens_API_Settings__c.');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        // Build request body
        String body = 'grant_type=' + GRANT_TYPE +
                     '&client_id=' + EncodingUtil.urlEncode(settings.Client_ID__c, 'UTF-8') +
                     '&client_secret=' + EncodingUtil.urlEncode(settings.Client_Secret__c, 'UTF-8');
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            // Parse response
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String accessToken = (String) responseBody.get('access_token');
            Integer expiresIn = (Integer) responseBody.get('expires_in'); // seconds

            // Cache token with 5-minute buffer before expiration
            if (settings.Id == null) {
                settings = new Walgreens_API_Settings__c();
                settings.SetupOwnerId = UserInfo.getOrganizationId();
            }

            settings.Access_Token__c = accessToken;
            settings.Token_Expires_At__c = DateTime.now().addSeconds(expiresIn - 300); // 5 min buffer
            settings.Last_Token_Refresh__c = DateTime.now();

            upsert settings;

            return accessToken;
        } else {
            throw new WalgreensAPIException('Failed to obtain access token: ' + res.getStatus() + ' - ' + res.getBody());
        }
    }

    /**
     * @description Forces a token refresh (useful for testing or after credential changes)
     */
    public static void forceTokenRefresh() {
        Walgreens_API_Settings__c settings = Walgreens_API_Settings__c.getOrgDefaults();
        if (settings != null) {
            settings.Access_Token__c = null;
            settings.Token_Expires_At__c = null;
            update settings;
        }
        requestNewToken();
    }

    /**
     * @description Custom exception for OAuth errors
     */
    public class WalgreensAPIException extends Exception {}
}
