// Update the 10 Daily_Routine__c records with wellness data
List<Daily_Routine__c> routines = [SELECT Id, Date__c, Energy_Level_Morning__c, Energy_Level_Afternoon__c, Energy_Level_Evening__c, Mood__c, Stress_Level__c, Exercise_Completed__c, Exercise_Type__c, Water_Intake__c, Morning_Routine_Complete__c, Accomplished_Today__c, Challenges__c, Gratitude__c, Tomorrow_Priorities__c FROM Daily_Routine__c ORDER BY Date__c ASC LIMIT 10];

if(routines.size() >= 10) {
    // Day 1 (10 days ago) - High Energy
    routines[0].Energy_Level_Morning__c = 9;
    routines[0].Energy_Level_Afternoon__c = 9;
    routines[0].Energy_Level_Evening__c = 8;
    routines[0].Mood__c = 'Energized';
    routines[0].Stress_Level__c = 3;
    routines[0].Exercise_Completed__c = true;
    routines[0].Exercise_Type__c = 'Walk';
    routines[0].Water_Intake__c = 8;
    routines[0].Morning_Routine_Complete__c = true;
    routines[0].Accomplished_Today__c = 'Applied to 5 high-priority positions and completed LWC module';
    routines[0].Challenges__c = 'None';
    routines[0].Gratitude__c = 'Feeling focused and productive';
    routines[0].Tomorrow_Priorities__c = 'Continue job applications';

    // Day 2 - Medium-High Energy
    routines[1].Energy_Level_Morning__c = 8;
    routines[1].Energy_Level_Afternoon__c = 6;
    routines[1].Energy_Level_Evening__c = 7;
    routines[1].Mood__c = 'Focused';
    routines[1].Stress_Level__c = 4;
    routines[1].Exercise_Completed__c = true;
    routines[1].Exercise_Type__c = 'Stretching';
    routines[1].Water_Intake__c = 7;
    routines[1].Morning_Routine_Complete__c = true;
    routines[1].Accomplished_Today__c = 'Customized 3 resumes for targeted positions';
    routines[1].Challenges__c = 'Energy dipped after lunch but recovered';
    routines[1].Gratitude__c = 'Good solid day';
    routines[1].Tomorrow_Priorities__c = 'Follow up on applications';

    // Day 3 - Medium Energy
    routines[2].Energy_Level_Morning__c = 7;
    routines[2].Energy_Level_Afternoon__c = 5;
    routines[2].Energy_Level_Evening__c = 6;
    routines[2].Mood__c = 'Steady';
    routines[2].Stress_Level__c = 5;
    routines[2].Exercise_Completed__c = false;
    routines[2].Water_Intake__c = 6;
    routines[2].Morning_Routine_Complete__c = true;
    routines[2].Accomplished_Today__c = 'Completed planned study time';
    routines[2].Challenges__c = 'Felt fatigue, shortened job search to conserve energy';
    routines[2].Gratitude__c = 'Managed to complete study goals';
    routines[2].Tomorrow_Priorities__c = 'Focus on self-care';

    // Day 4 - Low Energy
    routines[3].Energy_Level_Morning__c = 4;
    routines[3].Energy_Level_Afternoon__c = 4;
    routines[3].Energy_Level_Evening__c = 4;
    routines[3].Mood__c = 'Managing';
    routines[3].Stress_Level__c = 7;
    routines[3].Exercise_Completed__c = false;
    routines[3].Water_Intake__c = 5;
    routines[3].Morning_Routine_Complete__c = false;
    routines[3].Accomplished_Today__c = 'Focused on one quality application';
    routines[3].Challenges__c = 'Pain flared up today';
    routines[3].Gratitude__c = 'Adjusted schedule appropriately';
    routines[3].Tomorrow_Priorities__c = 'Rest and recovery';

    // Day 5 - Flare Day
    routines[4].Energy_Level_Morning__c = 2;
    routines[4].Energy_Level_Afternoon__c = 2;
    routines[4].Energy_Level_Evening__c = 2;
    routines[4].Mood__c = 'Resting';
    routines[4].Stress_Level__c = 8;
    routines[4].Exercise_Completed__c = false;
    routines[4].Water_Intake__c = 4;
    routines[4].Morning_Routine_Complete__c = false;
    routines[4].Accomplished_Today__c = 'Complete rest day';
    routines[4].Challenges__c = 'Fibro flare';
    routines[4].Gratitude__c = 'No guilt about productivity - health first';
    routines[4].Tomorrow_Priorities__c = 'Continue resting';

    // Day 6 - Recovery
    routines[5].Energy_Level_Morning__c = 3;
    routines[5].Energy_Level_Afternoon__c = 3;
    routines[5].Energy_Level_Evening__c = 3;
    routines[5].Mood__c = 'Recovering';
    routines[5].Stress_Level__c = 7;
    routines[5].Exercise_Completed__c = false;
    routines[5].Water_Intake__c = 6;
    routines[5].Morning_Routine_Complete__c = false;
    routines[5].Accomplished_Today__c = '30 min of light review reading';
    routines[5].Challenges__c = 'Still recovering from flare';
    routines[5].Gratitude__c = 'Extra sleep helped';
    routines[5].Tomorrow_Priorities__c = 'Gradual return to routine';

    // Day 7 - Bounce Back
    routines[6].Energy_Level_Morning__c = 6;
    routines[6].Energy_Level_Afternoon__c = 6;
    routines[6].Energy_Level_Evening__c = 6;
    routines[6].Mood__c = 'Hopeful';
    routines[6].Stress_Level__c = 5;
    routines[6].Exercise_Completed__c = true;
    routines[6].Exercise_Type__c = 'Yoga';
    routines[6].Water_Intake__c = 7;
    routines[6].Morning_Routine_Complete__c = true;
    routines[6].Accomplished_Today__c = 'Deployed wellness system to Salesforce, applied to 2 remote positions';
    routines[6].Challenges__c = 'Energy improved throughout day';
    routines[6].Gratitude__c = 'Feeling better!';
    routines[6].Tomorrow_Priorities__c = 'Build on this momentum';

    // Day 8 - Strong Day
    routines[7].Energy_Level_Morning__c = 8;
    routines[7].Energy_Level_Afternoon__c = 8;
    routines[7].Energy_Level_Evening__c = 8;
    routines[7].Mood__c = 'Accomplished';
    routines[7].Stress_Level__c = 3;
    routines[7].Exercise_Completed__c = true;
    routines[7].Exercise_Type__c = 'Walk';
    routines[7].Water_Intake__c = 8;
    routines[7].Morning_Routine_Complete__c = true;
    routines[7].Accomplished_Today__c = 'Fixed API integration issues and completed flow deployments, applied to 4 positions including dream job';
    routines[7].Challenges__c = 'None';
    routines[7].Gratitude__c = 'Great momentum!';
    routines[7].Tomorrow_Priorities__c = 'Continue system testing';

    // Day 9 - Steady Progress
    routines[8].Energy_Level_Morning__c = 7;
    routines[8].Energy_Level_Afternoon__c = 7;
    routines[8].Energy_Level_Evening__c = 7;
    routines[8].Mood__c = 'Balanced';
    routines[8].Stress_Level__c = 4;
    routines[8].Exercise_Completed__c = true;
    routines[8].Exercise_Type__c = 'Stretching';
    routines[8].Water_Intake__c = 7;
    routines[8].Morning_Routine_Complete__c = true;
    routines[8].Accomplished_Today__c = 'Worked on sample data creation and system testing';
    routines[8].Challenges__c = 'None';
    routines[8].Gratitude__c = 'Feeling good about progress';
    routines[8].Tomorrow_Priorities__c = 'Finalize testing';

    // Day 10 - Variable Energy
    routines[9].Energy_Level_Morning__c = 6;
    routines[9].Energy_Level_Afternoon__c = 4;
    routines[9].Energy_Level_Evening__c = 5;
    routines[9].Mood__c = 'Adaptable';
    routines[9].Stress_Level__c = 5;
    routines[9].Exercise_Completed__c = false;
    routines[9].Water_Intake__c = 6;
    routines[9].Morning_Routine_Complete__c = true;
    routines[9].Accomplished_Today__c = 'Morning was productive';
    routines[9].Challenges__c = 'Afternoon required rest';
    routines[9].Gratitude__c = 'Listening to body signals';
    routines[9].Tomorrow_Priorities__c = 'Continue being flexible';

    update routines;
    System.debug('✅ SUCCESS! Updated ' + routines.size() + ' Daily Routine records with wellness data');
} else {
    System.debug('❌ ERROR: Found ' + routines.size() + ' records, expected 10');
}
