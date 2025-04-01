import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:trans_quechua/translations/services/api_service.dart';
import 'package:trans_quechua/translations/services/record_service.dart';
import 'button_translate.widget.dart';

class TranslatePage extends StatefulWidget {
  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String _translatedText = "Traducción aquí...";
  bool _isLoading = false;
  File? _lastRecordedAudio;
  Duration? _audioDuration;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _handleTranslation(bool isQuechua) async {
    try {
      setState(() => _isLoading = true);

      final audio = await grabarAudio(context);
      if (audio == null) return;

      _lastRecordedAudio = audio;

      // Obtener duración
      final playerTemp = AudioPlayer();
      await playerTemp.setSource(DeviceFileSource(audio.path));
      await Future.delayed(Duration(milliseconds: 200)); // esperar un poco

      final duration = await playerTemp.getDuration();
      await playerTemp.dispose(); // libera recursos
      setState(() {
        _audioDuration = duration;
      });

      final result =
          isQuechua
              ? await ApiService.transcribeQuechua(audio)
              : await ApiService.transcribeSpanish(audio);

      if (result != null) {
        setState(() => _translatedText = result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo traducir el audio.")),
        );
      }
    } catch (e) {
      print("❌ Error de traducción: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playRecordedAudio() async {
    if (_lastRecordedAudio == null) return;

    if (_isPlaying) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.play(DeviceFileSource(_lastRecordedAudio!.path));
    }

    setState(() => _isPlaying = !_isPlaying);

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => _isPlaying = false);
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${duration.inMinutes}:${twoDigits(duration.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("IA: Quechua-Español")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Panel Superior
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(24),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _translatedText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.volume2, color: Colors.deepPurple),
                  onPressed: () async {
                    final audio = await ApiService.synthesizeSpeech(
                      _translatedText,
                      isQuechua: false, // cambiar si es texto en Quechua
                    );
                    if (audio != null) {
                      await AudioPlayer().play(DeviceFileSource(audio.path));
                    }
                  },
                ),
              ],
            ),
          ),

          // ▶ Botón para reproducir el audio grabado
          if (_lastRecordedAudio != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                  onPressed: _playRecordedAudio,
                ),
                SizedBox(width: 8),
                Text(
                  "Original: ${_formatDuration(_audioDuration)}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),

          // Botones
          if (_isLoading)
            CircularProgressIndicator()
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildTranslateButton(
                    icon: LucideIcons.mic,
                    text: "Traducir Quechua",
                    color: Colors.deepPurple,
                    onTap: () => _handleTranslation(true),
                  ),
                  buildTranslateButton(
                    icon: LucideIcons.mic,
                    text: "Traducir Español",
                    color: Colors.orange,
                    onTap: () => _handleTranslation(false),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Future<File?> grabarAudio(BuildContext context) async {
  await initRecorder();

  await startRecording();

  // Mostrar un diálogo temporal para detener la grabación
  return showDialog<File>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text("Grabando..."),
        content: Text("Toca 'Detener' cuando termines de hablar."),
        actions: [
          TextButton(
            onPressed: () async {
              final file = await stopRecording();
              Navigator.of(ctx).pop(file);
            },
            child: Text("Detener"),
          ),
        ],
      );
    },
  );
}
