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
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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

      print("✅ Diccionarios cargados");
    } catch (e) {
      print("❌ Error al cargar diccionarios: $e");
    }
  }

  Map<String, String> getFilteredDictionary() {
    final dictionary = isQuechuaToSpanish ? quechuaToSpanish : spanishToQuechua;
    if (searchQuery.isEmpty) return dictionary;

    return Map.fromEntries(
      dictionary.entries.where(
        (entry) => entry.key.toLowerCase().contains(searchQuery.toLowerCase()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDictionary = getFilteredDictionary();

    return Scaffold(
      appBar: AppBar(title: Text("Diccionario"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    isQuechuaToSpanish
                        ? 'Buscar en quechua o español...'
                        : 'Buscar en español o quechua...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child:
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
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isQuechuaToSpanish = true;
                  searchQuery = '';
                  _searchController.clear();
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
                  searchQuery = '';
                  _searchController.clear();
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
