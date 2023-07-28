/**
 * This class provides an invocable method to generate chat responses using the OpenAI API.
 * The method receives a list of ChatGPTVariable objects, each containing a prompt and the number of tokens for the API response.
 */
public class ChatGPTInvocable {
  /**
   * Represents a single chat prompt and the number of tokens for the API response.
   */
  public class ChatGPTVariable {
    /**
     * The prompt for the API call.
     */
    @InvocableVariable(required=true label='Text Prompt')
    public String prompt;

    /**
     * The number of tokens for the API response.
     */
    @InvocableVariable(required=false label='Number of tokens')
    public Integer numberOfTokens;
  }

  /**
   * Generates chat responses using the OpenAI API based on the provided prompts and parameters.
   * @param variables List of ChatGPTVariable objects, each containing a prompt and the number of tokens for the API response.
   * @return List of strings representing the generated chat responses.
   */
  @InvocableMethod(label='Generate Chat Responses')
  public static List<ChatGPTResponse> generateChatResponses(
    List<ChatGPTVariable> variables
  ) {
    List<ChatGPTResponse> responseWrappers = new List<ChatGPTResponse>();

    for (ChatGPTVariable variable : variables) {
      String prompt = variable.prompt;
      Integer numberOfTokens = variable.numberOfTokens;
      List<String> textChoices = new List<String>();
      ChatGPTResponse response = new ChatGPTResponse();

      // Make the API call to OpenAI and get the response
      ChatGPTCallout.AIResponseWrapper responseWrapper = ChatGPTCallout.callOpenAI(
        prompt,
        numberOfTokens
      );

      for (ChatGPTCallout.AIChoice choice : responseWrapper.choices) {
        textChoices.add(choice.text);
      }
      response.choices = textChoices;
      responseWrappers.add(response);
    }

    return responseWrappers;
  }

  /**
   * Represents a single chat prompt and the number of tokens for the API response.
   */
  public class ChatGPTResponse {
    /**
     * The prompt for the API call.
     */
    @InvocableVariable(label='List of text choices to return')
    public List<String> choices;
  }
}
