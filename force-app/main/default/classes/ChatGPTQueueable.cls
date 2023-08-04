/**
 * This class represents a queueable job that uses the OpenAI API to generate
 * responses for a list of records. Each record's ID is associated with the
 * AI-generated response for that record.
 */
public class ChatGPTQueueable implements Queueable, Database.AllowsCallouts {
  private Map<Id, String> textPrompts; // List of IDs to process

  /**
   * Constructs a new instance of the ChatGPTQueueable class with a list of record IDs.
   * @param recordIds The list of record IDs to process.
   */
  public ChatGPTQueueable(Map<Id, String> textPrompts) {
    this.textPrompts = textPrompts;
  }

  /**
   * This method is automatically executed when the Salesforce job is queued.
   * It processes each record's ID and sends a request to the OpenAI API.
   * The responses for each record ID are processed and can be used for further actions.
   * @param context The context information for the queueable job.
   */
  public void execute(QueueableContext context) {
    ChatGPTCalloutLogger logger = ChatGPTCalloutLogger.getInstance();
    Map<Id, String> responses = new Map<Id, String>();

    for (Id recordId : textPrompts.keySet()) {
      // Customize the prompt and other parameters for your specific use case.
      String prompt = textPrompts.get(recordId);
      ChatGPTCallout.AIResponseWrapper responseWrapper = ChatGPTCallout.callOpenAI(
        prompt,
        250,
        'Trigger'
      );

      if (responseWrapper != null && responseWrapper.choices != null) {
        responses.put(recordId, responseWrapper.choices[0].text);
      }
    }

    // Process the responses as needed.
    insertChatterPosts(responses);
    Database.insert(logger.getLogs(), false);
  }

  private Database.SaveResult[] insertChatterPosts(
    Map<Id, String> mapOfResponses
  ) {
    List<FeedItem> feedItems = new List<FeedItem>();

    for (Id recordId : mapOfResponses.keySet()) {
      FeedItem post = new FeedItem(
        ParentId = recordId,
        IsRichText = true,
        body = mapOfResponses.get(recordId)
      );
      feedItems.add(post);
    }

    return Database.insert(feedItems, false);
  }
}
