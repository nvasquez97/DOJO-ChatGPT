/**
 * This class handles the callout to the OpenAI API to generate a response
 * for a given prompt. It processes the HTTP response and returns the AI-generated response as a string.
 */
public class ChatGPTCallout {
  /**
   * Makes a callout to the OpenAI API using the provided API key and prompt.
   * @param apiKey The OpenAI API key for authentication.
   * @param prompt The prompt to be sent to the OpenAI API.
   * @return The AI-generated response as a string.
   */
  public static AIResponseWrapper callOpenAI(String prompt) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:OpenAI/v1/engines/text-davinci-003/completions');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');

    Integer maxTokens = 150;

    Map<String, Object> requestBody = new Map<String, Object>();
    requestBody.put('prompt', prompt);
    requestBody.put('max_tokens', maxTokens);

    req.setBody(JSON.serialize(requestBody));

    Http http = new Http();
    HttpResponse res = http.send(req);

    return processResponse(res);
  }

  /**
   * Processes the HttpResponse and handles different error codes.
   * @param res The HttpResponse received from the OpenAI API call.
   * @return The AI-generated response as a string (if successful), null otherwise.
   */
  private static AIResponseWrapper processResponse(HttpResponse res) {
    Integer statusCode = res.getStatusCode();

    if (statusCode == 200) {
      AIResponseWrapper responseWrapper = new AIResponseWrapper(res.getBody());
      return responseWrapper;
    } else if (statusCode == 401) {
      System.debug('Error 401: Unauthorized');
      // Perform appropriate error handling for 401 error.
    } else if (statusCode == 403) {
      System.debug('Error 403: Forbidden');
      // Perform appropriate error handling for 403 error.
    } else if (statusCode == 404) {
      System.debug('Error 404: Not Found');
      // Perform appropriate error handling for 404 error.
    } else {
      System.debug('Error: ' + statusCode + ' - ' + res.getStatus());
      // Perform appropriate error handling for other error codes.
    }

    return null;
  }

  /**
   * This class represents a wrapper for processing the response received from the OpenAI API.
   * It helps deserialize the JSON response into a more structured format.
   */
  public class AIResponseWrapper {
    /**
     * The list of AI-generated choices obtained from the OpenAI API response.
     */
    public List<AIChoice> choices;

    /**
     * Constructs a new instance of the AIResponseWrapper class by deserializing the JSON response.
     * @param json The JSON response received from the OpenAI API call.
     */
    public AIResponseWrapper(String bodyString) {
      AIResponseWrapper tempWrapper = (AIResponseWrapper) JSON.deserialize(
        bodyString,
        AIResponseWrapper.class
      );
      this.choices = tempWrapper.choices;
    }
  }

  /**
   * This class represents an individual AI-generated choice obtained from the OpenAI API response.
   * It contains the text of the completion, the finish probability, and the index of the choice.
   */
  public class AIChoice {
    /**
     * The text of the AI-generated completion.
     */
    public String text;

    /**
     * The probability that the model has finished generating the response.
     * A value close to 1 indicates a high likelihood of completion.
     */
    public Integer finishProbability;

    /**
     * The index of the choice in the list of completions.
     */
    public Integer index;

    /**
     * Constructs a new instance of the AIChoice class.
     * @param text The text of the AI-generated completion.
     * @param finishProbability The probability that the model has finished generating the response.
     * @param index The index of the choice in the list of completions.
     */
    public AIChoice(String text, Integer finishProbability, Integer index) {
      this.text = text;
      this.finishProbability = finishProbability;
      this.index = index;
    }
  }
}
