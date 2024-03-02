import 'package:chat_gpt_eg/constants/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String baseUrl = dotenv.env[Constants.baseUrl]!;
String chatGPTApiKey = dotenv.env[Constants.chatgptApiKey]!;
String elevenLabsBaseUrl = dotenv.env[Constants.elevenLabsBaseUrl]!;
String elevenLabsApiKey = dotenv.env[Constants.elevenLabsApiKey]!;
