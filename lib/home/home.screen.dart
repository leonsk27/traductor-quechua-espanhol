import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trans_quechua/auth/login.screen.dart';
import 'package:trans_quechua/dictionary/dictionary.page.dart';
import 'package:trans_quechua/home/welcome.page.dart';
import 'package:trans_quechua/translations/translate.page.dart';
import 'package:trans_quechua/tutorial/tutorial.page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    WelcomePage(),
    TranslatePage(),
    DictionaryPage(),
    TutorialPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context); // Cerrar el menú al seleccionar una opción
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Traductor Inteligente")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Usuario",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Bienvenida'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.translate),
              title: Text('Traducir'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Diccionario'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Tutorial'),
              onTap: () => _onItemTapped(3),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
