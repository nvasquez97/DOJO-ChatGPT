public without sharing class ChatGPTCalloutLogger {
  public List<ChatGPTCallout__c> logs;
  private static ChatGPTCalloutLogger instance;

  private ChatGPTCalloutLogger() {
    logs = new List<ChatGPTCallout__c>();
  }

  public static ChatGPTCalloutLogger getInstance() {
    instance = instance != null ? instance : new ChatGPTCalloutLogger();
    return instance;
  }

  public Boolean addLog(ChatGPTCallout__c log) {
    this.logs.add(log);

    return true;
  }

  public List<ChatGPTCallout__c> getLogs() {
    return this.logs;
  }

  /**
   * Logs the ChatGPT callout on a custom object for analysis and tracking purposes.
   * @param prompt The prompt sent in the API request.
   * @param maxTokens The number of tokens for the API response.
   * @param responseWrapper The AIResponseWrapper containing the response from the OpenAI API.
   * @param isSuccess A boolean indicating whether the callout was successful.
   * @param errorMessage Any error message encountered during the callout (if applicable).
   * @param userIP The IP address of the user making the API call.
   */
  public static ChatGPTCallout__c logChatGPTCallout(
    String prompt,
    Integer maxTokens,
    ChatGPTCallout.AIResponseWrapper responseWrapper,
    HttpResponse response,
    Datetime requestTimestamp,
    String source
  ) {
    ChatGPTCallout__c calloutLog = new ChatGPTCallout__c();

    // Logging the request details
    calloutLog.Request_Timestamp__c = requestTimestamp;
    calloutLog.Input_Token_Count__c = prompt?.split(' ').size();
    calloutLog.Text_Prompt__c = prompt;
    calloutLog.Max_Number_of_Tokens__c = maxTokens;
    calloutLog.Source__c = source;

    // Logging the response details (if available)
    if (
      responseWrapper != null &&
      responseWrapper.choices != null &&
      !responseWrapper.choices.isEmpty()
    ) {
      ChatGPTCallout.AIChoice firstChoice = responseWrapper.choices.get(0);
      calloutLog.Response_Timestamp__c = Datetime.now();
      calloutLog.Response_Text__c = firstChoice.text;
      calloutLog.Output_Token_Count__c = firstChoice.text?.split(' ').size();
      calloutLog.Finish_Probability__c = firstChoice.finishProbability;
      calloutLog.Response_index__c = firstChoice.index;
    }

    // Logging status and error (if applicable)
    calloutLog.Satus__c = response.getStatusCode() >= 400 ? 'Error' : 'Success';
    //calloutLog.Error_Message__c =  response.getStatusCode() >= 400 ? response.getBody().substring(0, 250) : '';

    // Logging the user IP
    calloutLog.User_IP__c = [
      SELECT Id, SourceIp
      FROM AuthSession
      WHERE UsersId = :UserInfo.getUserId()
      ORDER BY CreatedDate DESC
      LIMIT 1
    ]
    .SourceIp;
    //logs.add(calloutLog);

    return calloutLog;
  }
}
