/**
 * @description Test class for RoutineTaskTimerService
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
@isTest
private class RoutineTaskTimerServiceTest {

    @testSetup
    static void setup() {
        // Create daily routine
        Daily_Routine__c routine = new Daily_Routine__c(
            Date__c = Date.today()
        );
        insert routine;

        // Create task timers with varying durations
        List<Routine_Task_Timer__c> timers = new List<Routine_Task_Timer__c>();

        for (Integer i = 0; i < 5; i++) {
            timers.add(new Routine_Task_Timer__c(
                Daily_Routine__c = routine.Id,
                Task_Name__c = 'Exercise',
                Start_Time__c = DateTime.now().addDays(-i).addHours(-1),
                End_Time__c = DateTime.now().addDays(-i),
                Expected_Duration_Minutes__c = 30,
                Was_Skipped__c = false
            ));
        }

        for (Integer i = 0; i < 3; i++) {
            timers.add(new Routine_Task_Timer__c(
                Daily_Routine__c = routine.Id,
                Task_Name__c = 'Meditation',
                Start_Time__c = DateTime.now().addDays(-i).addHours(-1),
                End_Time__c = DateTime.now().addDays(-i).addMinutes(-30),
                Expected_Duration_Minutes__c = 15,
                Was_Skipped__c = false
            ));
        }

        insert timers;
    }

    @isTest
    static void testStartTask() {
        Daily_Routine__c routine = [SELECT Id FROM Daily_Routine__c LIMIT 1];

        Test.startTest();
        Routine_Task_Timer__c timer = RoutineTaskTimerService.startTask(routine.Id, 'Exercise');
        Test.stopTest();

        System.assertNotEquals(null, timer, 'Timer should be created');
        System.assertNotEquals(null, timer.Id, 'Timer should be inserted');
        System.assertEquals(routine.Id, timer.Daily_Routine__c);
        System.assertEquals('Exercise', timer.Task_Name__c);
        System.assertNotEquals(null, timer.Start_Time__c, 'Should have start time');
    }

    @isTest
    static void testStopTask() {
        Daily_Routine__c routine = [SELECT Id FROM Daily_Routine__c LIMIT 1];
        Routine_Task_Timer__c timer = RoutineTaskTimerService.startTask(routine.Id, 'Breakfast');

        Test.startTest();
        Routine_Task_Timer__c stoppedTimer = RoutineTaskTimerService.stopTask(timer.Id);
        Test.stopTest();

        System.assertNotEquals(null, stoppedTimer.End_Time__c, 'Should have end time');
    }

    @isTest
    static void testGetAverageTaskDuration() {
        Test.startTest();
        Decimal avgDuration = RoutineTaskTimerService.getAverageTaskDuration('Exercise', 30);
        Test.stopTest();

        System.assertNotEquals(null, avgDuration, 'Should calculate average');
        System.assert(avgDuration > 0, 'Average should be positive');
    }

    @isTest
    static void testGetAverageTaskDuration_NoData() {
        Test.startTest();
        Decimal avgDuration = RoutineTaskTimerService.getAverageTaskDuration('Nonexistent Task', 30);
        Test.stopTest();

        System.assertEquals(null, avgDuration, 'Should return null when no data');
    }

    @isTest
    static void testFindBottlenecks() {
        Test.startTest();
        List<RoutineTaskTimerService.TaskBottleneck> bottlenecks =
            RoutineTaskTimerService.findBottlenecks(UserInfo.getUserId());
        Test.stopTest();

        System.assertNotEquals(null, bottlenecks, 'Bottlenecks list should not be null');
        // Bottlenecks will vary based on test data duration calculations
    }

    @isTest
    static void testOptimizeRoutine() {
        Test.startTest();
        String suggestions = RoutineTaskTimerService.optimizeRoutine(UserInfo.getUserId());
        Test.stopTest();

        System.assertNotEquals(null, suggestions, 'Suggestions should not be null');
        System.assert(suggestions.length() > 0, 'Suggestions should have content');
    }

    @isTest
    static void testOptimizeRoutine_NoBottlenecks() {
        // Delete all timers to simulate no bottlenecks
        delete [SELECT Id FROM Routine_Task_Timer__c];

        Test.startTest();
        String suggestions = RoutineTaskTimerService.optimizeRoutine(UserInfo.getUserId());
        Test.stopTest();

        System.assert(suggestions.contains('smoothly'), 'Should indicate smooth routine');
    }

    @isTest
    static void testTaskBottleneck_Constructor() {
        RoutineTaskTimerService.TaskBottleneck bottleneck =
            new RoutineTaskTimerService.TaskBottleneck();

        System.assertEquals(0, bottleneck.avgDuration, 'Should default to 0');
        System.assertEquals(0, bottleneck.avgDelay, 'Should default to 0');
    }
}
