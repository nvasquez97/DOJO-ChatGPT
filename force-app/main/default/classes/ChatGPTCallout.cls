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
    public static String callOpenAI(String prompt) {
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
    private static String processResponse(HttpResponse res) {
        Integer statusCode = res.getStatusCode();

        if (statusCode == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String aiResponse = String.valueOf(responseMap.get('choices'));
            return aiResponse;
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
}
