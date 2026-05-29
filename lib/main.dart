import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// Point d'entrée principal de l'application Flutter
void main() {
  runApp(const MyApp());
}

// Widget racine de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Titre de l'application affiché dans le gestionnaire de tâches
      title: 'ContactHive',
      // Désactive la bannière "Debug" en haut à droite
      debugShowCheckedModeBanner: false,
      // Configuration du thème global de l'application
      theme: ThemeData(
        useMaterial3: true, // Utilise les derniers composants Material Design 3
        colorSchemeSeed: Colors.orange, // Génère une palette de couleurs basée sur l'orange
      ),
      // Définit la route de démarrage (ici l'écran de bienvenue)
      initialRoute: '/',
      // Table des matières de l'application (les différentes pages)
      routes: {
        '/': (context) => const WelcomeScreen(), // Page d'accueil/bienvenue
        '/login': (context) => const LoginScreen(), // Page de connexion
        '/home': (context) => const HomeScreen(), // Page principale (liste des contacts)
      },
    );
  }
}
