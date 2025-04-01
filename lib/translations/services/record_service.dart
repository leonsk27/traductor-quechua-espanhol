import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
bool _isRecorderInitialized = false;
// String? _lastRecordedPath; // 📌 Guarda la ruta actual

Future<void> initRecorder() async {
  final micStatus = await Permission.microphone.request();
  if (!micStatus.isGranted) {
    throw Exception('Micrófono denegado');
  }

  await _recorder.openRecorder();
  _isRecorderInitialized = true;
}

Future<void> startRecording() async {
  if (!_isRecorderInitialized) await initRecorder();

  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/audio.m4a'; // 📌 Archivo fijo

  // _lastRecordedPath = path;

  // Si el archivo existe, eliminarlo primero (por limpieza)
  final file = File(path);
  if (await file.exists()) await file.delete();

  await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);
  if (_recorder.isRecording) {
    print("✅ Grabación iniciada correctamente");
  } else {
    print("❌ Grabación NO iniciada");
  }
  print("🎙️ Grabando en: $path");
}

Future<File?> stopRecording() async {
  final path = await _recorder.stopRecorder();
  print("🛑 Grabación detenida: $path");

  if (path != null) {
    final file = File(path);

    // 🧪 Esperar un momento a que se escriba bien el archivo
    await Future.delayed(Duration(milliseconds: 300));

    if (await file.exists()) {
      final bytes = await file.length();
      print("📦 Tamaño del archivo: $bytes bytes");

      if (bytes > 2000) {
        return file;
      } else {
        print("⚠️ El archivo es demasiado pequeño, puede estar vacío.");
      }
    }
  }

  return null;
}
