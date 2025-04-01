import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DictionaryPage extends StatefulWidget {
  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  bool isQuechuaToSpanish = true;
  Map<String, String> quechuaToSpanish = {};
  Map<String, String> spanishToQuechua = {};

  @override
  void initState() {
    super.initState();
    loadDictionaries();
  }

  Future<void> loadDictionaries() async {
    try {
      final quechuaJson = await rootBundle.loadString(
        'assets/dictionaries/quechua_espanol_diccionario.json',
      );
      final espanolJson = await rootBundle.loadString(
        'assets/dictionaries/espanol_quechua_diccionario.json',
      );

      setState(() {
        quechuaToSpanish = Map<String, String>.from(json.decode(quechuaJson));
        spanishToQuechua = Map<String, String>.from(json.decode(espanolJson));
      });

      print(
        "✅ Diccionarios cargados: Q→E ${quechuaToSpanish.length}, E→Q ${spanishToQuechua.length}",
      );
    } catch (e) {
      print("❌ Error al cargar diccionarios: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDictionary =
        isQuechuaToSpanish ? quechuaToSpanish : spanishToQuechua;

    return Scaffold(
      appBar: AppBar(title: Text("Diccionario"), centerTitle: true),
      body:
          currentDictionary.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: currentDictionary.length,
                itemBuilder: (context, index) {
                  String key = currentDictionary.keys.elementAt(index);
                  String value = currentDictionary[key]!;
                  return ListTile(
                    title: Text(
                      key,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(value),
                  );
                },
              ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isQuechuaToSpanish = true;
                });
              },
              child: Text("Quechua → Español"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isQuechuaToSpanish ? Colors.green : null,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isQuechuaToSpanish = false;
                });
              },
              child: Text("Español → Quechua"),
              style: ElevatedButton.styleFrom(
                backgroundColor: !isQuechuaToSpanish ? Colors.green : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
