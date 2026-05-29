import 'dart:convert'; // Package nécessaire pour transformer le texte JSON brut en objets Dart (Map, List)
import 'package:http/http.dart' as http; // Package pour effectuer des requêtes réseau (GET, POST, etc.)
import '../models/contact.dart'; // Importation du modèle 'Contact' pour transformer les données en objets réels

/// 🌐 CLASSE APISERVICE
/// Cette classe est le "moteur" de données de l'application.
/// Elle centralise tous les échanges avec internet et gère la liste des contacts en mémoire.
class ApiService {
  
  // 🔗 URL de l'API externe 'RandomUser' qui génère 20 contacts aléatoires pour nos tests.
  static const String _usersUrl = 'https://randomuser.me/api/?results=20';
  
  // 💾 MÉMOIRE CACHE (Variable statique)
  // Cette liste stocke les contacts en "mémoire vive" tant que l'application est ouverte.
  // Cela permet de modifier ou supprimer des contacts instantanément sans avoir besoin d'une base de données complexe.
  static List<Contact> _cachedContacts = [];

  /// 🔐 MÉTHODE : CONNEXION (LOGIN)
  /// Simule une phase d'authentification.
  /// Elle attend 300ms (pour imiter un temps de réponse serveur) et accepte toujours la connexion.
  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // Accès autorisé par défaut pour faciliter le développement.
  }

  /// 📡 MÉTHODE : TÉLÉCHARGEMENT DEPUIS L'API (INTERNET)
  /// C'est ici que l'application contacte réellement internet pour récupérer des données fraîches.
  static Future<List<Contact>> fetchFromApi() async {
    try {
      // 1. On lance la requête de téléchargement à l'adresse (URL) définie plus haut.
      final response = await http.get(Uri.parse(_usersUrl));

      // 2. On vérifie si le serveur a bien répondu (Code 200 signifie "Succès").
      if (response.statusCode == 200) {
        // 3. On décode le texte JSON reçu pour en faire une structure Map (clé/valeur).
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // 4. On extrait la liste brute des utilisateurs située dans la clé 'results'.
        final List<dynamic> results = data['results'];
        
        // 5. On transforme chaque élément JSON en un objet 'Contact' utilisable par Flutter.
        _cachedContacts = results.map((json) => Contact.fromJson(json)).toList();
        
        // On renvoie la liste finale.
        return _cachedContacts;
      } else {
        // Cas où le serveur distant rencontre un problème.
        throw Exception('Le serveur ne répond pas (Erreur ${response.statusCode})');
      }
    } catch (e) {
      // Cas où le téléphone n'a pas internet (Wi-Fi coupé ou mode avion).
      throw Exception('Erreur réseau : Impossible de contacter le serveur.');
    }
  }

  /// 👥 MÉTHODE : OBTENIR LES CONTACTS (FONCTION PRINCIPALE)
  /// Cette fonction est appelée par vos écrans (Accueil et Détails).
  /// Elle est optimisée : si on a déjà des contacts en mémoire, elle les donne tout de suite.
  /// [forceRefresh] : Si vrai, on ignore la mémoire et on télécharge de nouvelles données.
  static Future<List<Contact>> getContacts({bool forceRefresh = false}) async {
    if (_cachedContacts.isEmpty || forceRefresh) {
      // Si on n'a rien en mémoire ou si on demande de rafraîchir, on va sur internet.
      return await fetchFromApi();
    }
    // Sinon, on renvoie les données stockées (chargement instantané).
    return _cachedContacts;
  }

  /// ➕ MÉTHODE : AJOUTER UN CONTACT
  /// Insère manuellement un contact au tout début de notre liste en mémoire (Index 0).
  static void addContact(Contact newContact) {
    _cachedContacts.insert(0, newContact);
  }

  /// 📝 MÉTHODE : MODIFIER UN CONTACT
  /// Cherche un contact par son identifiant (ID) et remplace ses informations par les nouvelles.
  static void updateContact(Contact updatedContact) {
    // On localise l'emplacement du contact dans notre liste.
    final index = _cachedContacts.indexWhere((c) => c.id == updatedContact.id);
    
    // Si on le trouve, on écrase l'ancienne version par la nouvelle.
    if (index != -1) {
      _cachedContacts[index] = updatedContact;
    }
  }

  /// 🗑️ MÉTHODE : SUPPRIMER UN CONTACT
  /// Retire définitivement un contact de la mémoire locale en utilisant son ID unique.
  static void deleteContact(String id) {
    // On filtre la liste pour enlever l'élément dont l'ID correspond.
    _cachedContacts.removeWhere((c) => c.id == id);
  }
}
