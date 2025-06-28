import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:trans_quechua/translations/services/api_service.dart';
import 'package:trans_quechua/translations/services/record_service.dart';

class TranslatePage extends StatefulWidget {
  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage>
    with SingleTickerProviderStateMixin {
  String _translatedText = "Traducción aquí...";
  bool _isLoading = false;
  bool _isTranslating = false;
  File? _lastRecordedAudio;
  Duration? _audioDuration;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool isQuechua = true;
  double _micSize = 80;
  late AnimationController _pulseController;
  void _changingState() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleTranslation(bool isQuechua) async {
    try {
      setState(() {
        _translatedText = "Traduciendo...";
        _isTranslating = true;
      });
      // final audio = await grabarAudio(context);
      final audio = _lastRecordedAudio;
      if (audio == null) return;

      // _lastRecordedAudio = audio;

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
        setState(() {
          _translatedText = result;
          _isTranslating = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo traducir el audio.")),
        );
      }
    } catch (e) {
      print("❌ Error de traducción: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isTranslating = false;
      });
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isQuechua ? "IA: Quechua a Español" : "IA: Español a Quechua",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Panel superior
              Container(
                padding: EdgeInsets.all(24),
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Color.fromARGB(255, 23, 255, 174),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _translatedText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 135, 145, 140),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.volume2,
                        color: Color.fromARGB(255, 23, 255, 174),
                      ),
                      onPressed: () async {
                        final audio = await ApiService.synthesizeSpeech(
                          _translatedText,
                          isQuechua: isQuechua,
                        );
                        if (audio != null) {
                          await AudioPlayer().play(
                            DeviceFileSource(audio.path),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              Spacer(),
              Text(
                _isLoading
                    ? "Hablando..."
                    : _isTranslating
                    ? "Traduciendo..."
                    : "Presiona para hablar.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 135, 145, 140),
                ),
              ),
              SizedBox(height: 20),
              // Micrófono
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_isLoading)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: _micSize + _pulseController.value * 40,
                          height: _micSize + _pulseController.value * 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent.withAlpha(
                              (80 * (1 - _pulseController.value)).toInt(),
                            ),
                          ),
                        );
                      },
                    ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: _micSize,
                    height: _micSize,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _isLoading
                              ? Colors.redAccent.withAlpha(120)
                              : Color.fromARGB(255, 23, 255, 174),
                      boxShadow:
                          _isLoading
                              ? [
                                BoxShadow(
                                  color: Colors.redAccent.withAlpha(120),
                                  blurRadius: 10,
                                ),
                              ]
                              : [],
                    ),
                    child: GestureDetector(
                      onLongPressStart: (_) async {
                        await initRecorder();
                        await startRecording();
                        setState(() {
                          _micSize = 120;
                          _isLoading = true;
                        });
                      },
                      onLongPressEnd: (_) async {
                        setState(() {
                          _micSize = 80;
                          _isLoading = false;
                        });
                        final file = await stopRecording();
                        if (file != null) {
                          _lastRecordedAudio = file;
                          await _handleTranslation(isQuechua);
                        }
                      },
                      child: Icon(
                        LucideIcons.mic,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Switch de idioma
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Español",
                    style: TextStyle(
                      color:
                          isQuechua
                              ? Colors.grey
                              : Color.fromARGB(255, 23, 255, 174),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    activeColor: Color.fromARGB(255, 23, 255, 174),
                    value: isQuechua,
                    onChanged: (value) {
                      setState(() => isQuechua = value);
                    },
                  ),
                  Text(
                    "Quechua",
                    style: TextStyle(
                      color:
                          isQuechua
                              ? Color.fromARGB(255, 23, 255, 174)
                              : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
