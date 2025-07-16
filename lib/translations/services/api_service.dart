import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiService {
  // static const String baseUrl =
  //     "https://quechua-spanish-api-148750046645.southamerica-east1.run.app";
  // "http://192.168.0.105:8080";
  static const String baseUrl =
      "https://translate-quechua-api-148750046645.us-central1.run.app";

  // POST: Texto → Audio Quechua o Español
  static Future<File?> synthesizeSpeech(
    String text, {
    required bool isQuechua,
  }) async {
    final endpoint =
        isQuechua ? "/parse_to_sound_quechua" : "/parse_to_sound_spanish";
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/output.mp3");
      await file.writeAsBytes(bytes);
      return file;
    } else {
      print("Error al sintetizar audio: ${response.statusCode}");
      return null;
    }
  }

  // POST: Audio Quechua → Texto Español
  static Future<String?> transcribeQuechua(File audioFile) async {
    return _uploadAudio(
      audioFile,
      "/transcribe_quechua_to_spanish_text",
      "spanish_translation",
    );
  }

  // POST: Audio Español → Texto Quechua
  static Future<String?> transcribeSpanish(File audioFile) async {
    return _uploadAudio(
      audioFile,
      "/transcribe_spanish_to_quechua_text",
      "quechua_translation",
    );
  }

  static Future<String?> _uploadAudio(
    File file,
    String endpoint,
    String resultKey,
  ) async {
    var request = http.MultipartRequest("POST", Uri.parse(baseUrl + endpoint));
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("Resultado: $json");
        print("Resultado: ${json[resultKey]}");
        return json[resultKey];
      } else {
        print("Error al transcribir: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      print("Excepción al enviar audio: $e");
      return null;
    }
  }

  static Future<File?> convertM4AToWav(File m4aFile) async {
    var uri = Uri.parse(
      "https://bktranslate.webolivia.com/public/api/convert-audio",
    );

    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("audio", m4aFile.path));

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/converted.wav");
        await file.writeAsBytes(bytes);
        return file;
      } else {
        print("Error en conversión: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Excepción al convertir: $e");
      return null;
    }
  }
}
