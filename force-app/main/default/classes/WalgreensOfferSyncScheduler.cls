/**
 * @description Schedulable class for weekly Walgreens coupon sync
 * - Runs every Sunday at 6am
 * - Launches WalgreensOfferSync batch job
 *
 * Schedule with Anonymous Apex:
 * String cronExp = '0 0 6 ? * SUN';
 * System.schedule('Walgreens Weekly Coupon Sync', cronExp, new WalgreensOfferSyncScheduler());
 */
public class WalgreensOfferSyncScheduler implements Schedulable {

    /**
     * @description Execute method called by scheduler
     * @param sc SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        // Launch batch job with default settings (100 coupons, batch size 50)
        WalgreensOfferSync batch = new WalgreensOfferSync();
        Database.executeBatch(batch, 50);
    }
}
