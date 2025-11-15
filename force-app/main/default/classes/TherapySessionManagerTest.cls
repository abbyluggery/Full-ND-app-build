/**
 * @description Test class for TherapySessionManager
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
@isTest
private class TherapySessionManagerTest {

    @testSetup
    static void setup() {
        // Create daily routine
        Daily_Routine__c routine = new Daily_Routine__c(
            Date__c = Date.today()
        );
        insert routine;

        // Create mood entries
        List<Mood_Entry__c> moods = new List<Mood_Entry__c>();
        for (Integer i = 0; i < 5; i++) {
            moods.add(new Mood_Entry__c(
                Mood_Score__c = 5,
                Energy_Score__c = 5,
                Time_of_Day__c = 'Morning',
                Timestamp__c = DateTime.now().addDays(-i)
            ));
        }
        insert moods;
    }

    @isTest
    static void testGetProtocolSteps_CBT() {
        Test.startTest();
        List<TherapySessionManager.TherapyStep> steps =
            TherapySessionManager.getProtocolSteps('CBT');
        Test.stopTest();

        System.assertNotEquals(null, steps, 'Steps should not be null');
        System.assertEquals(6, steps.size(), 'CBT should have 6 steps');
        System.assertEquals(1, steps[0].stepNumber, 'First step should be numbered 1');
        System.assertEquals('CBT', steps[0].therapyType, 'Should be CBT type');
    }

    @isTest
    static void testGetProtocolSteps_DBT() {
        Test.startTest();
        List<TherapySessionManager.TherapyStep> steps =
            TherapySessionManager.getProtocolSteps('DBT');
        Test.stopTest();

        System.assertEquals(4, steps.size(), 'DBT should have 4 steps');
    }

    @isTest
    static void testGetProtocolSteps_Grounding() {
        Test.startTest();
        List<TherapySessionManager.TherapyStep> steps =
            TherapySessionManager.getProtocolSteps('Grounding');
        Test.stopTest();

        System.assertEquals(5, steps.size(), 'Grounding should have 5 steps');
    }

    @isTest
    static void testGetProtocolSteps_Mindfulness() {
        Test.startTest();
        List<TherapySessionManager.TherapyStep> steps =
            TherapySessionManager.getProtocolSteps('Mindfulness');
        Test.stopTest();

        System.assertEquals(5, steps.size(), 'Mindfulness should have 5 steps');
    }

    @isTest
    static void testGetProtocolSteps_ACT() {
        Test.startTest();
        List<TherapySessionManager.TherapyStep> steps =
            TherapySessionManager.getProtocolSteps('ACT');
        Test.stopTest();

        System.assertEquals(4, steps.size(), 'ACT should have 4 steps');
    }

    @isTest
    static void testCreateTherapySession() {
        Test.startTest();
        Imposter_Syndrome_Session__c session =
            TherapySessionManager.createTherapySession('CBT', UserInfo.getUserId());
        Test.stopTest();

        System.assertNotEquals(null, session, 'Session should be created');
        System.assertNotEquals(null, session.Id, 'Session should be inserted');
        System.assertEquals('CBT', session.Session_Type__c, 'Should be CBT type');
        System.assertNotEquals(null, session.Start_Time__c, 'Should have start time');
    }

    @isTest
    static void testCompleteStep() {
        Imposter_Syndrome_Session__c session =
            TherapySessionManager.createTherapySession('CBT', UserInfo.getUserId());

        Test.startTest();
        Therapy_Step_Completion__c completion =
            TherapySessionManager.completeStep(session.Id, 1, 'Identified the trigger situation');
        Test.stopTest();

        System.assertNotEquals(null, completion, 'Completion should be created');
        System.assertNotEquals(null, completion.Id, 'Completion should be inserted');
        System.assertEquals(session.Id, completion.Imposter_Syndrome_Session__c);
        System.assertEquals(1, completion.Step_Number__c);
        System.assertEquals('CBT', completion.Therapy_Type__c);
        System.assertNotEquals(null, completion.Daily_Routine__c, 'Should link to daily routine');
    }

    @isTest
    static void testCalculateEffectiveness() {
        Imposter_Syndrome_Session__c session =
            TherapySessionManager.createTherapySession('CBT', UserInfo.getUserId());

        // Create completions with ratings
        List<Therapy_Step_Completion__c> completions = new List<Therapy_Step_Completion__c>();

        Daily_Routine__c routine = [SELECT Id FROM Daily_Routine__c LIMIT 1];

        for (Integer i = 1; i <= 3; i++) {
            Therapy_Step_Completion__c c = new Therapy_Step_Completion__c();
            c.Therapy_Type__c = 'CBT';
            c.Step_Number__c = i;
            c.Step_Name__c = 'Step ' + i;
            c.Imposter_Syndrome_Session__c = session.Id;
            c.Daily_Routine__c = routine.Id;
            c.Effectiveness_Rating__c = 7 + i; // 8, 9, 10
            completions.add(c);
        }
        insert completions;

        Test.startTest();
        Decimal effectiveness = TherapySessionManager.calculateEffectiveness(session.Id);
        Test.stopTest();

        System.assertNotEquals(null, effectiveness, 'Effectiveness should be calculated');
        System.assertEquals(9, effectiveness, 'Should be average of 8, 9, 10');
    }

    @isTest
    static void testCalculateEffectiveness_NoRatings() {
        Imposter_Syndrome_Session__c session =
            TherapySessionManager.createTherapySession('CBT', UserInfo.getUserId());

        Test.startTest();
        Decimal effectiveness = TherapySessionManager.calculateEffectiveness(session.Id);
        Test.stopTest();

        System.assertEquals(null, effectiveness, 'Should return null when no ratings');
    }

    @isTest
    static void testRecommendTherapy_LowMood() {
        // Update moods to be low
        List<Mood_Entry__c> moods = [SELECT Id, Mood_Score__c FROM Mood_Entry__c];
        for (Mood_Entry__c m : moods) {
            m.Mood_Score__c = 3; // Low mood
        }
        update moods;

        Test.startTest();
        String recommendation = TherapySessionManager.recommendTherapy(UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals('Grounding', recommendation, 'Should recommend Grounding for low mood');
    }

    @isTest
    static void testRecommendTherapy_ModerateMood() {
        // Moods are already at 5 (moderate)
        Test.startTest();
        String recommendation = TherapySessionManager.recommendTherapy(UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals('DBT', recommendation, 'Should recommend DBT for moderate mood');
    }

    @isTest
    static void testRecommendTherapy_HighMood() {
        // Update moods to be high
        List<Mood_Entry__c> moods = [SELECT Id, Mood_Score__c FROM Mood_Entry__c];
        for (Mood_Entry__c m : moods) {
            m.Mood_Score__c = 8; // High mood
        }
        update moods;

        Test.startTest();
        String recommendation = TherapySessionManager.recommendTherapy(UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals('CBT', recommendation, 'Should recommend CBT for high mood');
    }

    @isTest
    static void testRecommendTherapy_NoData() {
        delete [SELECT Id FROM Mood_Entry__c];

        Test.startTest();
        String recommendation = TherapySessionManager.recommendTherapy(UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals('CBT', recommendation, 'Should default to CBT when no data');
    }
}
