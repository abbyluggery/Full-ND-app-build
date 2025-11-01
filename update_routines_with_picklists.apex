// Update Daily_Routine records with correct picklist values
String query = 'SELECT Id, Date__c FROM Daily_Routine__c ORDER BY Date__c ASC LIMIT 10';
List<SObject> routines = Database.query(query);

if(routines.size() >= 10) {
    // Day 1 - High Energy (Mood: Great, Stress: Calm)
    routines[0].put('Mood__c', 'Great');
    routines[0].put('Stress_Level__c', 'Calm');

    // Day 2 - Medium-High Energy (Mood: Good, Stress: Mild)
    routines[1].put('Mood__c', 'Good');
    routines[1].put('Stress_Level__c', 'Mild');

    // Day 3 - Medium Energy (Mood: Okay, Stress: Moderate)
    routines[2].put('Mood__c', 'Okay');
    routines[2].put('Stress_Level__c', 'Moderate');

    // Day 4 - Low Energy (Mood: Low, Stress: High)
    routines[3].put('Mood__c', 'Low');
    routines[3].put('Stress_Level__c', 'High');

    // Day 5 - Flare Day (Mood: Very Low, Stress: High)
    routines[4].put('Mood__c', 'Very Low');
    routines[4].put('Stress_Level__c', 'High');

    // Day 6 - Recovery (Mood: Low, Stress: High)
    routines[5].put('Mood__c', 'Low');
    routines[5].put('Stress_Level__c', 'High');

    // Day 7 - Bounce Back (Mood: Okay, Stress: Moderate)
    routines[6].put('Mood__c', 'Okay');
    routines[6].put('Stress_Level__c', 'Moderate');

    // Day 8 - Strong Day (Mood: Great, Stress: Calm)
    routines[7].put('Mood__c', 'Great');
    routines[7].put('Stress_Level__c', 'Calm');

    // Day 9 - Steady Progress (Mood: Good, Stress: Mild)
    routines[8].put('Mood__c', 'Good');
    routines[8].put('Stress_Level__c', 'Mild');

    // Day 10 - Variable Energy (Mood: Okay, Stress: Moderate)
    routines[9].put('Mood__c', 'Okay');
    routines[9].put('Stress_Level__c', 'Moderate');

    update routines;
    System.debug('✅ SUCCESS! Updated all 10 Daily Routine records with Mood and Stress Level!');
    System.debug('Mood pattern: Great → Very Low (flare) → Low (recovery) → Great (strong)');
    System.debug('Stress pattern: Calm → High (flare) → High (recovery) → Calm (strong)');
} else {
    System.debug('❌ ERROR: Found ' + routines.size() + ' records, expected 10');
}
