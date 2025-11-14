/**
 * @description Trigger on EmailMessage to update Opportunity stage when application email is sent
 * @author Abby Luggery / Claude Code Assistant
 * @date November 13, 2025
 */
trigger EmailMessageTrigger on EmailMessage (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityProgressAutomation.handleApplicationEmailSent(Trigger.new);
    }
}
