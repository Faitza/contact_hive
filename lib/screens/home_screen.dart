import 'dart:io'; // Importation pour gérer les fichiers locaux (comme les photos du téléphone)
import 'package:flutter/material.dart'; // Importation du framework UI de Flutter
import '../models/contact.dart'; // Importation du modèle de données Contact
import '../services/api_service.dart'; // Importation du service qui gère les appels réseaux
import 'detail_screen.dart'; // Importation de l'écran de détails pour la navigation

/// 🏠 CLASSE HOMESCREEN
/// Cet écran est le tableau de bord principal de l'application.
/// Il utilise un StatefulWidget car son contenu change (chargement des données).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- 📦 VARIABLES D'ÉTAT (DONNÉES) ---
  List<Contact> _contacts = []; // Liste vide qui contiendra les contacts récupérés de l'API
  bool _isLoading = false;      // Variable pour savoir si on affiche le chargement (spinner)

  @override
  void initState() {
    super.initState();
    // La méthode initState est appelée une seule fois à la création de l'écran.
    // On en profite pour lancer le chargement des données.
    _loadData();
  }

  /// 🌐 MÉTHODE : CHARGEMENT DES DONNÉES
  /// Récupère la liste des contacts depuis l'ApiService de manière asynchrone.
  void _loadData() async {
    // On déclenche le chargement : on change l'état pour afficher le spinner.
    setState(() => _isLoading = true);
    
    // On appelle le service et on attend la réponse.
    final data = await ApiService.getContacts();
    
    // Une fois les données reçues, on met à jour la liste et on arrête le spinner.
    setState(() {
      _contacts = data;
      _isLoading = false;
    });
  }

  /// 🚪 MÉTHODE : DÉCONNEXION
  /// Affiche une boîte de dialogue pour demander confirmation avant de quitter.
  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          // Bouton pour rester sur l'écran actuel
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          // Bouton pour confirmer le départ (affiché en rouge)
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    // Si l'utilisateur a cliqué sur "Quitter", on le redirige vers l'écran de Login.
    if (result == true) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// 🖼️ MÉTHODE : CHOIX DE L'IMAGE
  /// Vérifie si le contact a une image locale (galerie) ou s'il faut charger l'image réseau.
  ImageProvider _getAvatarImage(Contact contact) {
    if (contact.localImagePath != null && contact.localImagePath!.isNotEmpty) {
      return FileImage(File(contact.localImagePath!)); // Image stockée sur le téléphone
    }
    return NetworkImage(contact.imageUrl); // Image provenant d'internet
  }

  @override
  Widget build(BuildContext context) {
    // On extrait les 6 premiers contacts de la liste pour l'affichage "Récents"
    final recentContacts = _contacts.take(6).toList();

    return Scaffold(
      // 🎨 DESIGN : Fond de l'écran avec un dégradé de couleurs
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4E6), Color(0xFFFAF6F0)], // Couleurs orange clair et beige
          ),
        ),
        child: SafeArea(
          // SafeArea évite que le contenu touche les bords système (heure, batterie)
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.orange)) // Spinner si chargement
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0), // Marge autour de tout le contenu
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏢 SECTION : EN-TÊTE (Custom AppBar)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bonjour ! 👋', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                        const Text('ContactHive', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
                      onPressed: _logout, // Appel de la fonction déconnexion
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Espace vertical

                // 📊 SECTION : STATISTIQUES (Carte Blanche)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.orange.shade100,
                        child: Icon(Icons.people, size: 30, color: Colors.orange.shade800),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total des contacts', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 4),
                          // Affiche dynamiquement le nombre de contacts dans la liste
                          Text('${_contacts.length} Actifs', style: TextStyle(fontSize: 24, color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ⚡ SECTION : ACTIONS RAPIDES (Boutons Bleus et Oranges)
                const Text('Actions rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Bouton Rechercher : Renvoie vers l'écran de recherche/détails
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DetailScreen()));
                        },
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text('Rechercher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bouton Ajouter : Renvoie vers l'écran de création
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DetailScreen()));
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // 👥 SECTION : CONTACTS RÉCENTS (Liste Horizontale)
                const Text('Ajoutés récemment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: recentContacts.isEmpty
                      ? Center(
                    child: Text('Aucun contact pour le moment.', style: TextStyle(color: Colors.grey.shade600)),
                  )
                      : ListView.builder(
                    scrollDirection: Axis.horizontal, // Défilement horizontal
                    itemCount: recentContacts.length,
                    itemBuilder: (context, index) {
                      final contact = recentContacts[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigue vers les détails du contact au clic sur sa photo
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailScreen(contact: contact)),
                          ).then((_) => _loadData()); // Rafraîchit les données au retour
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                                  ],
                                ),
                                child: CircleAvatar(radius: 28, backgroundImage: _getAvatarImage(contact)),
                              ),
                              const SizedBox(height: 8),
                              // Affiche Prénom et l'initiale du Nom
                              Text(
                                '${contact.firstName} ${contact.lastName[0]}.',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // 🧭 BARRE DE NAVIGATION INFÉRIEURE
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Indique que nous sommes sur l'onglet Accueil
        selectedItemColor: Colors.orange.shade800,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: (index) {
          // Si on clique sur l'onglet Détails (index 1), on change d'écran
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, anim1, anim2) => const DetailScreen(),
                transitionDuration: Duration.zero, // Pas d'animation pour plus de fluidité
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Détails'),
        ],
      ),
    );
  }
}
