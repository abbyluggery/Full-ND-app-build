/**
 * @description Test class for DailyRoutineInvocable
 * Tests the invocable method for Flow integration
 */
@isTest
private class DailyRoutineInvocableTest {

    /**
     * @description Test successful invocable method execution
     */
    @isTest
    static void testGetAdaptiveSchedule_Success() {
        // Create test request
        DailyRoutineInvocable.Request req = new DailyRoutineInvocable.Request();
        req.energyLevel = 7;  // Medium energy day
        req.mood = 'Good';
        req.morningRoutineComplete = true;

        List<DailyRoutineInvocable.Request> requests = new List<DailyRoutineInvocable.Request>{req};
        
        Test.startTest();
        List<DailyRoutineInvocable.Result> results = DailyRoutineInvocable.getAdaptiveSchedule(requests);
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        
        DailyRoutineInvocable.Result result = results[0];
        System.assertEquals(true, result.success);
        System.assertEquals('Medium', result.energyCategory);
        System.assertEquals(3, result.studyHours);
        System.assertEquals(1.5, result.jobSearchHours);
        System.assertEquals('2-3 applications', result.applicationGoal);
        System.assert(result.todaysSchedule != null && result.todaysSchedule.length() > 0);
        System.assert(result.motivationalMessage != null && result.motivationalMessage.length() > 0);
    }
}
