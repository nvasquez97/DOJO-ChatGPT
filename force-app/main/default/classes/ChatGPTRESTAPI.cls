@RestResource(urlMapping='/chatGPTCallout/*')
global class ChatGPTRESTAPI {
  // Apex inner class representing the request body
  global class ChatGPTRequest {
    global String prompt;
    global Integer maxTokens;
  }

  // Apex inner class representing the response from OpenAI API
  global class ChatGPTResponse {
    global List<ChatGPTCallout.AIChoice> choices;

    public ChatGPTResponse(List<ChatGPTCallout.AIChoice> choices) {
      this.choices = choices;
    }
  }

  @HttpPost
  global static ChatGPTResponse makeChatGPTCallout() {
    ChatGPTCalloutLogger logger = ChatGPTCalloutLogger.getInstance();

    // Make the API call to OpenAI and get the response
    ChatGPTRequest request = (ChatGPTRequest) System.JSON.deserialize(
      RestContext.request.requestBody.toString(),
      ChatGPTRequest.class
    );
    ChatGPTCallout.AIResponseWrapper responseWrapper = ChatGPTCallout.callOpenAI(
      request.prompt,
      request.maxTokens,
      'API'
    );

    Database.insert(logger.getLogs(), false);

    if (responseWrapper != null && responseWrapper.choices != null) {
      return new ChatGPTResponse(responseWrapper.choices);
    } else {
      return new ChatGPTResponse(new List<ChatGPTCallout.AIChoice>());
    }
  }
}
