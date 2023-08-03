/**
 * LeadTriggerHandler is a trigger handler class for handling Lead triggers.
 * This class provides functionality to process Lead records after they are inserted.
 */
public class LeadTriggerHandler {
  public static void handleAll(
    List<Lead> newLeads,
    List<Lead> oldLeads,
    Map<Id, Lead> newLeadsMap,
    Map<Id, Lead> oldLeadsMap,
    System.TriggerOperation triggerOperation
  ) {
    if (triggerOperation == System.TriggerOperation.AFTER_INSERT) {
      handleAfterInsert(newLeads);
    }
  }

  /**
   * Handles the after insert context for the Lead trigger.
   * Creates a map of Lead IDs and corresponding chat prompts.
   * Enqueues a job of the ChatGPTQueueable class, passing the map of prompts as a parameter.
   *
   * @param newLeads The list of Lead records that were inserted.
   */
  public static void handleAfterInsert(List<Lead> newLeads) {
    Map<Id, String> leadIdToPromptMap = new Map<Id, String>();

    for (Lead lead : newLeads) {
      String prompt = 'Tell me about the Company ' + lead.Company;
      leadIdToPromptMap.put(lead.Id, prompt);
    }

    // Enqueue the ChatGPTQueueable job with the map of prompts as a parameter
    System.enqueueJob(new ChatGPTQueueable(leadIdToPromptMap));
  }
}
