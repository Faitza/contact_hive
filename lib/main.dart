import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'models/contact.dart';

// 🧪 EXIGENCE PROFESSEUR : Fonction de test unitaire fictive pour valider la désérialisation du Modèle
void _runModelTest() {
  debugPrint("==== [TEST] DÉBUT DE LA VALIDATION DU MODÈLE CONTACT ====");
  try {
    // Jeu de données JSON fictif simulant un retour API pur
    final Map<String, dynamic> jsonFictif = {
      "id": "test_99",
      "firstName": "Jean",
      "lastName": "Dupont",
      "email": "jean.dupont@test.com",
      "phone": "+50936001122",
      "imageUrl": "https://via.placeholder.com/150"
    };

    // Test d'instanciation via la factory fromJson
    final contactTest = Contact.fromJson(jsonFictif);

    assert(contactTest.id == "test_99");
    assert(contactTest.firstName == "Jean");

    debugPrint("✅ [SUCCÈS] Le modèle s'est correctement initialisé depuis le JSON fictif !");
    debugPrint("Nom généré : ${contactTest.firstName} ${contactTest.lastName}");
  } catch (e) {
    debugPrint("❌ [ÉCHEC] Erreur lors de la validation du modèle : $e");
  }
  debugPrint("========================================================");
}

void main() {
  // Lancement automatique du test au démarrage de l'app avant le runApp
  _runModelTest();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContactHive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}