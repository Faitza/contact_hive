import 'dart:convert'; // Importation pour convertir le JSON reçu en structures Dart (Map/List)
import 'package:http/http.dart' as http; // Importation du package HTTP pour faire les requêtes réseau
import '../models/contact.dart'; // Importation de ton modèle Contact

/// 🌐 CLASSE APISERVICE
/// Regroupe toutes les requêtes réseau de l'application et la gestion des données en mémoire locale.
class ApiService {

  // URL de l'API Random User demandant 50 utilisateurs avec des données en français (fr)
  static const String _baseUrl = 'https://randomuser.me/api/?results=50&nat=fr';

  // 📦 CACHE LOCAL (En Mémoire) : Permet de stocker les contacts pour pouvoir faire le CRUD en local

  static final List<Contact> _localContactsCache = [];

  /// 👥 MÉTHODE : RÉCUPÉRATION DES CONTACTS depuis Random User (ou depuis le cache local)
  static Future<List<Contact>> getContacts() async {
    try {
      // Si le cache contient déjà des données, on les retourne directement au lieu de rappeler l'API.
      // Cela évite de perdre les contacts ajoutés ou modifiés lors d'un rafraîchissement.
      if (_localContactsCache.isNotEmpty) {
        return _localContactsCache;
      }

      // 1. Envoi de la requête GET asynchrone à l'API
      final response = await http.get(Uri.parse(_baseUrl));

      // 2. Vérification du code statut HTTP (200 = Succès)
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final List<dynamic> results = decodedData['results'];

        // 3. Transformation (Mapping) du JSON reçu en objets Contact
        final fetchedContacts = results.map((userJson) {
          return Contact.fromJson({
            "id": userJson['login']['uuid'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            "firstName": userJson['name']['first'] ?? '',
            "lastName": userJson['name']['last'] ?? '',
            "email": userJson['email'] ?? '',
            "phone": userJson['phone'] ?? '',
            "imageUrl": userJson['picture']['large'] ?? '',
          });
        }).toList();

        // On remplit notre cache local avec les données initiales de l'API
        _localContactsCache.addAll(fetchedContacts);
        return _localContactsCache;

      } else {
        throw Exception('Erreur serveur : Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossible de charger les contacts : $e');
    }
  }

  /// ➕ MÉTHODE : AJOUTER UN CONTACT
  /// Ajoute un nouveau contact créé manuellement dans notre liste locale.
  static void addContact(Contact contact) {
    _localContactsCache.insert(0, contact); // Ajoute au début de la liste pour qu'il soit visible de suite
  }

  /// 🔄 MÉTHODE : MODIFIER UN CONTACT
  /// Parcourt la liste locale pour trouver le contact par son ID et met à jour ses infos.
  static void updateContact(Contact updatedContact) {
    final index = _localContactsCache.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      _localContactsCache[index] = updatedContact;
    }
  }

  /// ❌ MÉTHODE : SUPPRIMER UN CONTACT
  /// Supprime un contact de la liste locale à partir de son identifiant unique.
  static void deleteContact(String id) {
    _localContactsCache.removeWhere((c) => c.id == id);
  }

  /// 🔐 MÉTHODE : CONNEXION (AUTHENTIFICATION)
  /// Simule une vérification d'identifiants asynchrone pour l'écran de Login.
  static Future<bool> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500)); // Simulation délai réseau
      if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception("Erreur lors de la tentative de connexion : $e");
    }
  }
}