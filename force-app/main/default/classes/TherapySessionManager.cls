/**
 * @description Manage guided therapy exercises (CBT, DBT, ACT, Grounding)
 * Track step completion and measure effectiveness
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
public with sharing class TherapySessionManager {

    /**
     * @description Load therapy protocol steps for a specific therapy type
     * @param therapyType The therapy type (CBT, DBT, ACT, Mindfulness, Grounding)
     * @return List<TherapyStep> The protocol steps
     */
    public static List<TherapyStep> getProtocolSteps(String therapyType) {
        List<TherapyStep> steps = new List<TherapyStep>();

        if (therapyType == 'CBT') {
            steps.add(new TherapyStep(1, 'Identify the situation', 'Describe the situation that triggered the negative thought.', 'CBT'));
            steps.add(new TherapyStep(2, 'Identify automatic thoughts', 'What thoughts automatically came to mind?', 'CBT'));
            steps.add(new TherapyStep(3, 'Identify emotions', 'What emotions did you feel? Rate intensity 1-10.', 'CBT'));
            steps.add(new TherapyStep(4, 'Find evidence for/against thought', 'List evidence that supports and contradicts the thought.', 'CBT'));
            steps.add(new TherapyStep(5, 'Generate alternative thought', 'Create a more balanced, realistic thought.', 'CBT'));
            steps.add(new TherapyStep(6, 'Re-rate emotion intensity', 'How intense is the emotion now? Rate 1-10.', 'CBT'));

        } else if (therapyType == 'DBT') {
            steps.add(new TherapyStep(1, 'Observe emotion without judgment', 'Notice the emotion without labeling it good or bad.', 'DBT'));
            steps.add(new TherapyStep(2, 'Describe emotion factually', 'Describe what you\'re feeling like a scientist would.', 'DBT'));
            steps.add(new TherapyStep(3, 'Practice opposite action', 'Do the opposite of what the emotion urges you to do.', 'DBT'));
            steps.add(new TherapyStep(4, 'Use distress tolerance skills', 'Use TIPP, ACCEPTS, or self-soothing techniques.', 'DBT'));

        } else if (therapyType == 'Grounding') {
            steps.add(new TherapyStep(1, '5 things you can see', 'Name 5 things you can see right now.', 'Grounding'));
            steps.add(new TherapyStep(2, '4 things you can touch', 'Name 4 things you can physically feel.', 'Grounding'));
            steps.add(new TherapyStep(3, '3 things you can hear', 'Name 3 things you can hear.', 'Grounding'));
            steps.add(new TherapyStep(4, '2 things you can smell', 'Name 2 things you can smell.', 'Grounding'));
            steps.add(new TherapyStep(5, '1 thing you can taste', 'Name 1 thing you can taste.', 'Grounding'));

        } else if (therapyType == 'Mindfulness') {
            steps.add(new TherapyStep(1, 'Find a quiet space', 'Sit comfortably in a quiet location.', 'Mindfulness'));
            steps.add(new TherapyStep(2, 'Focus on breath', 'Notice your breath moving in and out.', 'Mindfulness'));
            steps.add(new TherapyStep(3, 'Notice thoughts', 'When thoughts arise, acknowledge them without judgment.', 'Mindfulness'));
            steps.add(new TherapyStep(4, 'Return to breath', 'Gently return focus to your breathing.', 'Mindfulness'));
            steps.add(new TherapyStep(5, 'End mindfully', 'Slowly open eyes and notice how you feel.', 'Mindfulness'));

        } else if (therapyType == 'ACT') {
            steps.add(new TherapyStep(1, 'Accept the thought/feeling', 'Acknowledge the thought exists without fighting it.', 'ACT'));
            steps.add(new TherapyStep(2, 'Defuse from the thought', 'See the thought as just words, not facts.', 'ACT'));
            steps.add(new TherapyStep(3, 'Connect to values', 'What matters most to you? What do you value?', 'ACT'));
            steps.add(new TherapyStep(4, 'Take committed action', 'What action aligns with your values?', 'ACT'));
        }

        return steps;
    }

    /**
     * @description Create a new therapy session from a protocol
     * @param therapyType The therapy type
     * @param userId User ID
     * @return Imposter_Syndrome_Session__c The created session
     */
    public static Imposter_Syndrome_Session__c createTherapySession(String therapyType, Id userId) {
        Imposter_Syndrome_Session__c session = new Imposter_Syndrome_Session__c();
        session.Session_Type__c = therapyType;
        session.Start_Time__c = DateTime.now();

        insert session;
        return session;
    }

    /**
     * @description Record completion of a therapy step
     * @param sessionId The session ID
     * @param stepNumber The step number in the protocol
     * @param notes User's notes for this step
     * @return Therapy_Step_Completion__c The completion record
     */
    public static Therapy_Step_Completion__c completeStep(Id sessionId, Integer stepNumber, String notes) {
        // Get session to determine therapy type
        Imposter_Syndrome_Session__c session = [
            SELECT Id, Session_Type__c
            FROM Imposter_Syndrome_Session__c
            WHERE Id = :sessionId
            LIMIT 1
        ];

        // Get the step details
        List<TherapyStep> steps = getProtocolSteps(session.Session_Type__c);
        TherapyStep step = null;
        for (TherapyStep s : steps) {
            if (s.stepNumber == stepNumber) {
                step = s;
                break;
            }
        }

        // Create completion record
        Therapy_Step_Completion__c completion = new Therapy_Step_Completion__c();
        completion.Therapy_Type__c = session.Session_Type__c;
        completion.Step_Number__c = stepNumber;

        if (step != null) {
            completion.Step_Name__c = step.stepName;
        }

        completion.Completion_Time__c = DateTime.now();
        completion.Notes__c = notes;
        completion.Imposter_Syndrome_Session__c = sessionId;

        // Link to today's daily routine if exists
        List<Daily_Routine__c> routines = [
            SELECT Id
            FROM Daily_Routine__c
            WHERE Date__c = TODAY
            LIMIT 1
        ];

        if (!routines.isEmpty()) {
            completion.Daily_Routine__c = routines[0].Id;
        }

        insert completion;
        return completion;
    }

    /**
     * @description Calculate session effectiveness based on step ratings
     * @param sessionId The session ID
     * @return Decimal The effectiveness score (average of all step effectiveness ratings)
     */
    public static Decimal calculateEffectiveness(Id sessionId) {
        List<Therapy_Step_Completion__c> completions = [
            SELECT Id, Effectiveness_Rating__c
            FROM Therapy_Step_Completion__c
            WHERE Imposter_Syndrome_Session__c = :sessionId
            AND Effectiveness_Rating__c != null
        ];

        if (completions.isEmpty()) {
            return null;
        }

        Decimal total = 0;
        for (Therapy_Step_Completion__c c : completions) {
            total += c.Effectiveness_Rating__c;
        }

        return total / completions.size();
    }

    /**
     * @description Recommend therapy type based on user's mood patterns
     * @param userId User ID
     * @return String Recommended therapy type
     */
    public static String recommendTherapy(Id userId) {
        // Get recent mood data
        List<Mood_Entry__c> moods = [
            SELECT Id, Mood_Score__c, Notes__c
            FROM Mood_Entry__c
            WHERE CreatedDate = LAST_N_DAYS:7
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];

        if (moods.isEmpty()) {
            return 'CBT'; // Default recommendation
        }

        // Calculate average mood
        Decimal avgMood = 0;
        for (Mood_Entry__c m : moods) {
            avgMood += m.Mood_Score__c;
        }
        avgMood = avgMood / moods.size();

        // Simple recommendation logic
        if (avgMood < 4) {
            return 'Grounding'; // For intense distress, use grounding
        } else if (avgMood < 6) {
            return 'DBT'; // For moderate distress, use DBT skills
        } else {
            return 'CBT'; // For mild distress, use CBT restructuring
        }
    }

    /**
     * @description Inner class representing a therapy step
     */
    public class TherapyStep {
        public Integer stepNumber;
        public String stepName;
        public String instructions;
        public String therapyType;

        public TherapyStep(Integer stepNumber, String stepName, String instructions, String therapyType) {
            this.stepNumber = stepNumber;
            this.stepName = stepName;
            this.instructions = instructions;
            this.therapyType = therapyType;
        }
    }
}
