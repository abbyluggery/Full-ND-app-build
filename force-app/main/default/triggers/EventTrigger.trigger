/**
 * @description Trigger on Event to update Opportunity stage when interview events are created or completed
 * @author Abby Luggery / Claude Code Assistant
 * @date November 13, 2025
 */
trigger EventTrigger on Event (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityProgressAutomation.handleInterviewEventCreation(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityProgressAutomation.handleInterviewEventCompletion(Trigger.new, Trigger.oldMap);
    }
}
