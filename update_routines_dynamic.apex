// Update Daily_Routine records using dynamic SOQL/DML (bypasses API cache issues)
String query = 'SELECT Id, Date__c FROM Daily_Routine__c ORDER BY Date__c ASC LIMIT 10';
List<SObject> routines = Database.query(query);

if(routines.size() >= 10) {
    // Day 1 - High Energy
    routines[0].put('Energy_Level_Morning__c', 9);
    routines[0].put('Energy_Level_Afternoon__c', 9);
    routines[0].put('Energy_Level_Evening__c', 8);
    routines[0].put('Mood__c', 'Energized');
    routines[0].put('Stress_Level__c', 3);
    routines[0].put('Exercise_Completed__c', true);
    routines[0].put('Exercise_Type__c', 'Walk');
    routines[0].put('Water_Intake__c', 8);
    routines[0].put('Morning_Routine_Complete__c', true);
    routines[0].put('Accomplished_Today__c', 'Applied to 5 high-priority positions and completed LWC module');
    routines[0].put('Challenges__c', 'None');
    routines[0].put('Gratitude__c', 'Feeling focused and productive');
    routines[0].put('Tomorrow_Priorities__c', 'Continue job applications');

    // Day 2 - Medium-High Energy
    routines[1].put('Energy_Level_Morning__c', 8);
    routines[1].put('Energy_Level_Afternoon__c', 6);
    routines[1].put('Energy_Level_Evening__c', 7);
    routines[1].put('Mood__c', 'Focused');
    routines[1].put('Stress_Level__c', 4);
    routines[1].put('Exercise_Completed__c', true);
    routines[1].put('Exercise_Type__c', 'Stretching');
    routines[1].put('Water_Intake__c', 7);
    routines[1].put('Morning_Routine_Complete__c', true);
    routines[1].put('Accomplished_Today__c', 'Customized 3 resumes for targeted positions');
    routines[1].put('Challenges__c', 'Energy dipped after lunch but recovered');
    routines[1].put('Gratitude__c', 'Good solid day');
    routines[1].put('Tomorrow_Priorities__c', 'Follow up on applications');

    // Day 3 - Medium Energy
    routines[2].put('Energy_Level_Morning__c', 7);
    routines[2].put('Energy_Level_Afternoon__c', 5);
    routines[2].put('Energy_Level_Evening__c', 6);
    routines[2].put('Mood__c', 'Steady');
    routines[2].put('Stress_Level__c', 5);
    routines[2].put('Exercise_Completed__c', false);
    routines[2].put('Water_Intake__c', 6);
    routines[2].put('Morning_Routine_Complete__c', true);
    routines[2].put('Accomplished_Today__c', 'Completed planned study time');
    routines[2].put('Challenges__c', 'Felt fatigue, shortened job search to conserve energy');
    routines[2].put('Gratitude__c', 'Managed to complete study goals');
    routines[2].put('Tomorrow_Priorities__c', 'Focus on self-care');

    // Day 4 - Low Energy
    routines[3].put('Energy_Level_Morning__c', 4);
    routines[3].put('Energy_Level_Afternoon__c', 4);
    routines[3].put('Energy_Level_Evening__c', 4);
    routines[3].put('Mood__c', 'Managing');
    routines[3].put('Stress_Level__c', 7);
    routines[3].put('Exercise_Completed__c', false);
    routines[3].put('Water_Intake__c', 5);
    routines[3].put('Morning_Routine_Complete__c', false);
    routines[3].put('Accomplished_Today__c', 'Focused on one quality application');
    routines[3].put('Challenges__c', 'Pain flared up today');
    routines[3].put('Gratitude__c', 'Adjusted schedule appropriately');
    routines[3].put('Tomorrow_Priorities__c', 'Rest and recovery');

    // Day 5 - Flare Day
    routines[4].put('Energy_Level_Morning__c', 2);
    routines[4].put('Energy_Level_Afternoon__c', 2);
    routines[4].put('Energy_Level_Evening__c', 2);
    routines[4].put('Mood__c', 'Resting');
    routines[4].put('Stress_Level__c', 8);
    routines[4].put('Exercise_Completed__c', false);
    routines[4].put('Water_Intake__c', 4);
    routines[4].put('Morning_Routine_Complete__c', false);
    routines[4].put('Accomplished_Today__c', 'Complete rest day');
    routines[4].put('Challenges__c', 'Fibro flare');
    routines[4].put('Gratitude__c', 'No guilt about productivity - health first');
    routines[4].put('Tomorrow_Priorities__c', 'Continue resting');

    // Day 6 - Recovery
    routines[5].put('Energy_Level_Morning__c', 3);
    routines[5].put('Energy_Level_Afternoon__c', 3);
    routines[5].put('Energy_Level_Evening__c', 3);
    routines[5].put('Mood__c', 'Recovering');
    routines[5].put('Stress_Level__c', 7);
    routines[5].put('Exercise_Completed__c', false);
    routines[5].put('Water_Intake__c', 6);
    routines[5].put('Morning_Routine_Complete__c', false);
    routines[5].put('Accomplished_Today__c', '30 min of light review reading');
    routines[5].put('Challenges__c', 'Still recovering from flare');
    routines[5].put('Gratitude__c', 'Extra sleep helped');
    routines[5].put('Tomorrow_Priorities__c', 'Gradual return to routine');

    // Day 7 - Bounce Back
    routines[6].put('Energy_Level_Morning__c', 6);
    routines[6].put('Energy_Level_Afternoon__c', 6);
    routines[6].put('Energy_Level_Evening__c', 6);
    routines[6].put('Mood__c', 'Hopeful');
    routines[6].put('Stress_Level__c', 5);
    routines[6].put('Exercise_Completed__c', true);
    routines[6].put('Exercise_Type__c', 'Yoga');
    routines[6].put('Water_Intake__c', 7);
    routines[6].put('Morning_Routine_Complete__c', true);
    routines[6].put('Accomplished_Today__c', 'Deployed wellness system to Salesforce, applied to 2 remote positions');
    routines[6].put('Challenges__c', 'Energy improved throughout day');
    routines[6].put('Gratitude__c', 'Feeling better!');
    routines[6].put('Tomorrow_Priorities__c', 'Build on this momentum');

    // Day 8 - Strong Day
    routines[7].put('Energy_Level_Morning__c', 8);
    routines[7].put('Energy_Level_Afternoon__c', 8);
    routines[7].put('Energy_Level_Evening__c', 8);
    routines[7].put('Mood__c', 'Accomplished');
    routines[7].put('Stress_Level__c', 3);
    routines[7].put('Exercise_Completed__c', true);
    routines[7].put('Exercise_Type__c', 'Walk');
    routines[7].put('Water_Intake__c', 8);
    routines[7].put('Morning_Routine_Complete__c', true);
    routines[7].put('Accomplished_Today__c', 'Fixed API integration issues and completed flow deployments, applied to 4 positions including dream job');
    routines[7].put('Challenges__c', 'None');
    routines[7].put('Gratitude__c', 'Great momentum!');
    routines[7].put('Tomorrow_Priorities__c', 'Continue system testing');

    // Day 9 - Steady Progress
    routines[8].put('Energy_Level_Morning__c', 7);
    routines[8].put('Energy_Level_Afternoon__c', 7);
    routines[8].put('Energy_Level_Evening__c', 7);
    routines[8].put('Mood__c', 'Balanced');
    routines[8].put('Stress_Level__c', 4);
    routines[8].put('Exercise_Completed__c', true);
    routines[8].put('Exercise_Type__c', 'Stretching');
    routines[8].put('Water_Intake__c', 7);
    routines[8].put('Morning_Routine_Complete__c', true);
    routines[8].put('Accomplished_Today__c', 'Worked on sample data creation and system testing');
    routines[8].put('Challenges__c', 'None');
    routines[8].put('Gratitude__c', 'Feeling good about progress');
    routines[8].put('Tomorrow_Priorities__c', 'Finalize testing');

    // Day 10 - Variable Energy
    routines[9].put('Energy_Level_Morning__c', 6);
    routines[9].put('Energy_Level_Afternoon__c', 4);
    routines[9].put('Energy_Level_Evening__c', 5);
    routines[9].put('Mood__c', 'Adaptable');
    routines[9].put('Stress_Level__c', 5);
    routines[9].put('Exercise_Completed__c', false);
    routines[9].put('Water_Intake__c', 6);
    routines[9].put('Morning_Routine_Complete__c', true);
    routines[9].put('Accomplished_Today__c', 'Morning was productive');
    routines[9].put('Challenges__c', 'Afternoon required rest');
    routines[9].put('Gratitude__c', 'Listening to body signals');
    routines[9].put('Tomorrow_Priorities__c', 'Continue being flexible');

    update routines;
    System.debug('✅ SUCCESS! Updated ' + routines.size() + ' Daily Routine records with full wellness data!');
} else {
    System.debug('❌ ERROR: Found ' + routines.size() + ' records, expected 10');
}
