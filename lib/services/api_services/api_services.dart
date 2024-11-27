import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vote_tracker/services/api_services/ai_api_model.dart';

class ChatGptApiService {
  // Function to make the API call and return the model
  Future<ChatGPTAPIModel> sendChatGptRequest(String prompt) async {
    final url = Uri.parse("https://chatgpt-42.p.rapidapi.com/gpt4");

    final body = jsonEncode({
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "web_access": false,
    });

    final headers = {
      "x-rapidapi-key": "14383b7b13msh4ae41898bc4741fp1a962djsnce9ee391fc75",
      "x-rapidapi-host": "chatgpt-42.p.rapidapi.com",
      "Content-Type": "application/json",
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        final responseData = jsonDecode(response.body);
        return ChatGPTAPIModel.fromJson(responseData);
      } else {
        print(
            "Request failed with status: ${response.statusCode}, body: ${response.body}");
        throw Exception("Failed  Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
      throw Exception("Failed to load image, Status code: ${e.toString()}");
    }
  }
}
