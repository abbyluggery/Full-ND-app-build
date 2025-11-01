/**
 * @description Energy-Adaptive Scheduler for Neurodivergent Executive Function Support
 * Analyzes daily energy levels and provides adaptive schedule recommendations
 *
 * Supports 4 energy states:
 * - High Energy (8-10): Full schedule with 4 hrs study, 2 hrs job search, 4-5 applications
 * - Medium Energy (5-7): Adapted schedule with 3 hrs study, 1.5 hrs job search, 2-3 applications
 * - Low Energy (2-4): Minimum viable with 2 hrs study, 30-60 min job search, 1-2 applications
 * - Flare-up (1): Health first - morning routine only, rest without guilt
 *
 * @author Claude AI Assistant
 * @date 2025-10-29
 */
public with sharing class EnergyAdaptiveScheduler {

    /**
     * @description Analyzes today's energy level and returns adaptive schedule recommendations
     * @param dailyRoutineId The ID of today's Daily_Routine__c record
     * @return Map<String, Object> containing recommendations and schedule adjustments
     */
    public static Map<String, Object> getScheduleRecommendations(Id dailyRoutineId) {

        // Query today's Daily_Routine record
        Daily_Routine__c routine = [
            SELECT Id, Date__c, Energy_Level_Morning__c, Mood__c,
                   Morning_Routine_Complete__c, Stress_Level__c
            FROM Daily_Routine__c
            WHERE Id = :dailyRoutineId
            LIMIT 1
        ];

        // Determine energy category
        Decimal energy = routine.Energy_Level_Morning__c != null ? routine.Energy_Level_Morning__c : 5;
        String energyCategory = categorizeEnergy(energy);

        // Build recommendations
        Map<String, Object> recommendations = new Map<String, Object>();
        recommendations.put('energyLevel', energy);
        recommendations.put('energyCategory', energyCategory);
        recommendations.put('date', routine.Date__c);
        recommendations.put('mood', routine.Mood__c);

        // Get schedule based on energy category
        if (energyCategory == 'High') {
            recommendations.put('schedule', getHighEnergySchedule());
            recommendations.put('message', getHighEnergyMessage());
            recommendations.put('studyHours', 4);
            recommendations.put('jobSearchHours', 2);
            recommendations.put('applicationGoal', '4-5 applications');
        } else if (energyCategory == 'Medium') {
            recommendations.put('schedule', getMediumEnergySchedule());
            recommendations.put('message', getMediumEnergyMessage());
            recommendations.put('studyHours', 3);
            recommendations.put('jobSearchHours', 1.5);
            recommendations.put('applicationGoal', '2-3 applications');
        } else if (energyCategory == 'Low') {
            recommendations.put('schedule', getLowEnergySchedule());
            recommendations.put('message', getLowEnergyMessage());
            recommendations.put('studyHours', 2);
            recommendations.put('jobSearchHours', 1);
            recommendations.put('applicationGoal', '1-2 Quick Apply jobs');
        } else { // Flare-up
            recommendations.put('schedule', getFlareUpSchedule());
            recommendations.put('message', getFlareUpMessage());
            recommendations.put('studyHours', 0);
            recommendations.put('jobSearchHours', 0);
            recommendations.put('applicationGoal', 'Rest and recover');
        }

        return recommendations;
    }

    /**
     * @description Categorizes energy level into High/Medium/Low/Flare-up
     * @param energy Energy level (1-10 scale)
     * @return String category
     */
    private static String categorizeEnergy(Decimal energy) {
        if (energy >= 8) return 'High';
        if (energy >= 5) return 'Medium';
        if (energy >= 2) return 'Low';
        return 'Flare-up';
    }

    /**
     * @description Returns High Energy schedule
     */
    private static List<String> getHighEnergySchedule() {
        return new List<String>{
            '10:00 AM - 12:00 PM: Salesforce Study (2 hours)',
            '12:00 PM - 1:00 PM: Lunch & Break',
            '1:00 PM - 3:00 PM: Salesforce Study (2 hours)',
            '3:00 PM - 3:45 PM: Job Search Research (45 min)',
            '3:45 PM - 4:00 PM: Break',
            '4:00 PM - 5:00 PM: Applications & Networking (1 hour)',
            '5:00 PM: Hard stop - Rest earned!'
        };
    }

    /**
     * @description Returns Medium Energy schedule
     */
    private static List<String> getMediumEnergySchedule() {
        return new List<String>{
            '10:00 AM - 12:00 PM: Salesforce Study (2 hours)',
            '12:00 PM - 1:00 PM: Lunch & Break',
            '1:00 PM - 2:00 PM: Salesforce Study (1 hour)',
            '2:00 PM - 3:00 PM: Light review or rest',
            '3:00 PM - 3:30 PM: Job Search Research (30 min)',
            '3:30 PM - 3:45 PM: Break',
            '3:45 PM - 4:45 PM: Applications (2-3 jobs)',
            '5:00 PM: Hard stop - Honor your body!'
        };
    }

    /**
     * @description Returns Low Energy schedule
     */
    private static List<String> getLowEnergySchedule() {
        return new List<String>{
            '10:00 AM - 12:00 PM: Salesforce Study (2 hours light review)',
            '12:00 PM - 1:30 PM: Extended lunch & rest',
            '1:30 PM - 3:00 PM: Rest period (no pressure)',
            '3:00 PM - 3:20 PM: Quick job search (20 min)',
            '3:20 PM - 4:00 PM: 1-2 Quick Apply jobs',
            '4:00 PM: STOP - Rest is productive!'
        };
    }

    /**
     * @description Returns Flare-up schedule
     */
    private static List<String> getFlareUpSchedule() {
        return new List<String>{
            '7:30 AM - 8:00 AM: Slow wake-up (if possible)',
            '8:00 AM - 9:30 AM: Morning mindfulness (if possible)',
            '15 min email check (optional)',
            'Rest without guilt',
            'Self-care is not selfish',
            'Tomorrow is a new day'
        };
    }

    /**
     * @description Returns High Energy motivational message
     */
    private static String getHighEnergyMessage() {
        return 'High energy day! You have the capacity for a full schedule today. ' +
               'Take advantage of this energy while honoring your limits. You\'ve got this!';
    }

    /**
     * @description Returns Medium Energy message
     */
    private static String getMediumEnergyMessage() {
        return 'Medium energy day. This is your adapted schedule with built-in flexibility. ' +
               'Listen to your body and adjust as needed. Progress over perfection!';
    }

    /**
     * @description Returns Low Energy message
     */
    private static String getLowEnergyMessage() {
        return 'Low energy day. This is your minimum viable routine. ' +
               'Even small progress is real progress. Rest is productive. Be gentle with yourself.';
    }

    /**
     * @description Returns Flare-up message
     */
    private static String getFlareUpMessage() {
        return 'Flare-up protocol activated. HEALTH FIRST. Your only job today is self-care. ' +
               'No guilt. No pressure. Rest and recover. Tomorrow is a new day.';
    }

    /**
     * @description Analyzes patterns from past Daily_Routine records
     * @param days Number of days to analyze
     * @return Map<String, Object> containing pattern insights
     */
    public static Map<String, Object> analyzeEnergyPatterns(Integer days) {

        Date startDate = Date.today().addDays(-days + 1);

        List<Daily_Routine__c> routines = [
            SELECT Id, Date__c, Energy_Level_Morning__c, Mood__c,
                   Morning_Routine_Complete__c, Exercise_Completed__c
            FROM Daily_Routine__c
            WHERE Date__c >= :startDate
            ORDER BY Date__c DESC
        ];

        if (routines.isEmpty()) {
            return new Map<String, Object>{
                'hasData' => false,
                'message' => 'No data available yet. Keep logging your daily routines!'
            };
        }

        // Calculate averages
        Decimal totalEnergy = 0;
        Integer morningRoutineCount = 0;
        Integer exerciseCount = 0;
        Map<String, Integer> moodCounts = new Map<String, Integer>();

        for (Daily_Routine__c routine : routines) {
            if (routine.Energy_Level_Morning__c != null) {
                totalEnergy += routine.Energy_Level_Morning__c;
            }
            if (routine.Morning_Routine_Complete__c == true) {
                morningRoutineCount++;
            }
            if (routine.Exercise_Completed__c == true) {
                exerciseCount++;
            }
            if (routine.Mood__c != null) {
                Integer count = moodCounts.containsKey(routine.Mood__c) ?
                               moodCounts.get(routine.Mood__c) : 0;
                moodCounts.put(routine.Mood__c, count + 1);
            }
        }

        Decimal avgEnergy = routines.size() > 0 ? totalEnergy / routines.size() : 0;
        Decimal morningRoutineRate = routines.size() > 0 ?
            (Decimal)morningRoutineCount / routines.size() * 100 : 0;
        Decimal exerciseRate = routines.size() > 0 ?
            (Decimal)exerciseCount / routines.size() * 100 : 0;

        // Build insights
        Map<String, Object> insights = new Map<String, Object>();
        insights.put('hasData', true);
        insights.put('daysAnalyzed', routines.size());
        insights.put('avgEnergy', avgEnergy.setScale(1));
        insights.put('morningRoutineRate', morningRoutineRate.setScale(0));
        insights.put('exerciseRate', exerciseRate.setScale(0));
        insights.put('moodDistribution', moodCounts);

        // Generate recommendations
        List<String> recommendations = new List<String>();

        if (avgEnergy < 5) {
            recommendations.add('Your average energy is low. Consider: more sleep, ' +
                              'lighter workload, or consulting healthcare provider.');
        } else if (avgEnergy >= 7) {
            recommendations.add('Your energy levels are strong! Great work maintaining wellness.');
        }

        if (morningRoutineRate < 50) {
            recommendations.add('Morning routine completion is below 50%. This routine ' +
                              'is your foundation - prioritize it!');
        } else if (morningRoutineRate >= 80) {
            recommendations.add('Excellent morning routine consistency! This is building momentum.');
        }

        if (exerciseRate < 30) {
            recommendations.add('Low exercise frequency. Even 10 minutes of movement helps energy.');
        }

        insights.put('recommendations', recommendations);

        return insights;
    }
}
