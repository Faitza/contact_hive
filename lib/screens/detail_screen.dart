import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/contact.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

/// 📱 CLASSE DETAILSCREEN : Gère l'affichage approfondi des contacts.
/// Cette classe utilise deux modes d'affichage basés sur l'état :
/// 1. MODE LISTE : Affiche tous les contacts avec une barre de recherche (si _currentLocalContact est nul).
/// 2. MODE FICHE : Affiche les détails complets d'un contact sélectionné.
class DetailScreen extends StatefulWidget {
  // Le contact initialement passé à l'écran (peut être nul)
  final Contact? contact; 
  const DetailScreen({super.key, this.contact});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // ----------------------------------------------------------------------
  // 📦 VARIABLES D'ÉTAT (LES DONNÉES DE L'ÉCRAN)
  // ----------------------------------------------------------------------
  
  // Liste source contenant l'intégralité des contacts récupérés via l'API.
  List<Contact> _allContacts = [];      
  
  // Liste filtrée dynamiquement affichée à l'écran selon la recherche de l'utilisateur.
  List<Contact> _filteredContacts = []; 
  
  // Contrôleur permettant de manipuler et lire le texte saisi dans le champ de recherche.
  final TextEditingController _searchController = TextEditingController(); 
  
  // Indicateur visuel pour savoir si une requête réseau est en cours.
  bool _isLoading = false;             

  // Stocke temporairement le chemin d'une image sélectionnée dans la galerie avant sa validation.
  String? _tempFormImagePath;          

  // Référence locale du contact actuellement affiché en plein écran (fiche détail).
  Contact? _currentLocalContact;       

  // 🔒 CLÉS DE FORMULAIRE (SÉCURITÉ ET VALIDATION) :
  // Utilisées pour valider l'intégralité des champs d'un formulaire en une seule commande.
  final _addFormKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();

  // 📝 CONTRÔLEURS DE TEXTE : 
  // Utilisés pour extraire les valeurs saisies par l'utilisateur dans les formulaires.
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // ----------------------------------------------------------------------
  // ⚙️ INITIALISATION (CYCLE DE VIE)
  // ----------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Au lancement, si un contact a été transmis, on l'établit comme contact courant.
    if (widget.contact != null) {
      _currentLocalContact = widget.contact;
    }
    // Déclenche le chargement de la liste des contacts dès l'ouverture.
    _loadGlobalList(); 
    // Attache un "écouteur" sur le contrôleur de recherche pour filtrer à chaque caractère tapé.
    _searchController.addListener(_filterContacts); 
  }

  /// 🌐 MÉTHODE : CHARGEMENT DES DONNÉES
  /// Interroge l'ApiService pour obtenir la liste des contacts et met à jour l'interface.
  Future<void> _loadGlobalList({bool force = false}) async {
    // Affiche l'indicateur de chargement.
    setState(() => _isLoading = true); 
    try {
      // Appel asynchrone au service API.
      final data = await ApiService.getContacts(forceRefresh: force);
      setState(() {
        _allContacts = data;
        _filteredContacts = data;
        // Si un contact était déjà affiché, on rafraîchit ses informations depuis la nouvelle liste.
        if (_currentLocalContact != null) {
          _currentLocalContact = data.firstWhere(
            (c) => c.id == _currentLocalContact!.id, 
            orElse: () => _currentLocalContact!
          );
        }
      });
    } catch (e) {
      // Affiche une barre de message (SnackBar) en cas d'erreur réseau ou autre.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      // Masque l'indicateur de chargement une fois l'opération terminée (succès ou échec).
      setState(() => _isLoading = false); 
    }
  }

  /// 🔍 MÉTHODE : FILTRAGE DE LA LISTE
  /// Parcourt la liste globale et ne garde que les contacts dont le nom ou l'email contient la recherche.
  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final fullName = '${contact.firstName} ${contact.lastName}'.toLowerCase();
        // Vérifie si la requête est présente dans le nom complet ou dans l'email.
        return fullName.contains(query) || contact.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// 🚪 MÉTHODE : DÉCONNEXION
  /// Affiche un dialogue de confirmation. Si validé, redirige l'utilisateur vers l'écran de Login.
  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Souhaitez-vous fermer votre session ContactHive ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Quitter', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
    if (result == true) {
      // Remplace la route actuelle par la route de connexion.
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// 📸 MÉTHODE : SÉLECTION D'IMAGE
  /// Utilise le package ImagePicker pour choisir une photo depuis la source indiquée (Galerie/Caméra).
  Future<void> _pickImageForForm(StateSetter setDialogState, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      // setDialogState permet de redessiner spécifiquement l'intérieur du dialogue (Pop-up).
      setDialogState(() { _tempFormImagePath = image.path; });
    }
  }

  /// 🖼️ MÉTHODE : AFFICHAGE PLEIN ÉCRAN
  /// Permet de zoomer sur l'image du contact en l'affichant dans une boîte de dialogue modale.
  void _showFullImage(ImageProvider imageProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context), // Ferme l'image au clic.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image(image: imageProvider, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // ✅ SECTION : LOGIQUE DE VALIDATION (CONTRÔLE DES SAISIES)
  // ----------------------------------------------------------------------

  // Valide que le nom n'est pas vide et respecte les caractères autorisés.
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est obligatoire';
    final nameRegEx = RegExp(r"^[a-zA-ZÀ-ÿ\s\-'\s]+$");
    if (!nameRegEx.hasMatch(value.trim())) return 'Lettres uniquement (pas de chiffres)';
    return null;
  }

  // Valide que l'adresse email saisie respecte le format standard d'un email.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est obligatoire';
    final emailRegEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegEx.hasMatch(value.trim())) return 'Format d\'email invalide';
    return null;
  }

  // ----------------------------------------------------------------------
  // ➕ SECTION : GESTION DES FORMULAIRES (AJOUT)
  // ----------------------------------------------------------------------

  /// Affiche une fenêtre contextuelle pour créer un nouveau contact de zéro.
  void _showAddContactDialog() {
    // Réinitialise les contrôleurs pour éviter de garder les anciennes valeurs.
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _tempFormImagePath = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau Contact', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: _addFormKey, // Liaison indispensable pour activer la validation auto.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zone interactive pour sélectionner la photo de profil.
                  GestureDetector(
                    onTap: () => _pickImageForForm(setDialogState, ImageSource.gallery),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _tempFormImagePath != null ? FileImage(File(_tempFormImagePath!)) : null,
                      child: _tempFormImagePath == null ? const Icon(Icons.add_a_photo, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'Prénom'), validator: _validateName),
                  TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Nom'), validator: _validateName),
                  TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: _validateEmail),
                  TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                // Déclenche la validation de tous les champs via la clé de formulaire.
                if (_addFormKey.currentState!.validate()) {
                  final newC = Contact(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    firstName: _firstNameController.text.trim(),
                    lastName: _lastNameController.text.trim(),
                    email: _emailController.text.trim(),
                    phone: _phoneController.text.trim(),
                    imageUrl: 'https://via.placeholder.com/150',
                    localImagePath: _tempFormImagePath,
                  );
                  // Sauvegarde via le service.
                  ApiService.addContact(newC); 
                  Navigator.pop(context);      // Ferme le dialogue.
                  _loadGlobalList();           // Rafraîchit l'affichage.
                }
              },
              child: const Text('Ajouter', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 🖼️ GESTIONNAIRE D'IMAGE (AVATAR)
  // ----------------------------------------------------------------------

  /// Détermine si l'image doit être chargée depuis le stockage local (photo prise)
  /// ou via l'URL distante fournie par l'API.
  ImageProvider _getAvatar(Contact contact) {
    if (contact.localImagePath != null && contact.localImagePath!.isNotEmpty) {
      return FileImage(File(contact.localImagePath!));
    }
    return NetworkImage(contact.imageUrl);
  }

  // ----------------------------------------------------------------------
  // 🎨 MÉTHODE BUILD (DESSINE L'INTERFACE)
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // --- CAS 1 : MODE RECHERCHE (Aucun contact spécifique sélectionné) ---
    if (_currentLocalContact == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        appBar: AppBar(
          title: const Text('ContactHive', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Bouton de rafraîchissement manuel de la liste.
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadGlobalList(force: true)),
            // Bouton de déconnexion.
            IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _logout),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Barre de recherche interactive.
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un contact...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              // Liste des contacts (affichage dynamique).
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredContacts.isEmpty
                    ? const Center(child: Text('Aucun résultat trouvé.'))
                    : ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final c = _filteredContacts[index];
                    final avatar = _getAvatar(c);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () => _showFullImage(avatar), // Affiche l'image en grand.
                          child: CircleAvatar(backgroundImage: avatar),
                        ),
                        title: Text('${c.firstName} ${c.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c.email),
                        // Au clic : on passe en "Mode Fiche" pour ce contact.
                        onTap: () => setState(() { _currentLocalContact = c; }), 
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Bouton "+" flottant pour ajouter un nouveau contact.
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: _showAddContactDialog,
          child: const Icon(Icons.person_add, color: Colors.white),
        ),
        // Navigation de bas de page.
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1, // Indique que nous sommes sur l'onglet Détails.
          selectedItemColor: Colors.orange,
          onTap: (index) {
            // Si on clique sur l'onglet Accueil (index 0), on change d'écran.
            if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Détails'),
          ],
        ),
      );
    }

    // --- CAS 2 : MODE FICHE DÉTAIL (Un contact est sélectionné) ---
    final avatar = _getAvatar(_currentLocalContact!);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Bouton de retour : annule le contact courant pour revenir au Mode Recherche.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => setState(() { _currentLocalContact = null; }), 
        ),
        title: const Text('Fiche Contact', style: TextStyle(color: Colors.black87)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Grande photo de profil zoomable au toucher.
            Center(
              child: GestureDetector(
                onTap: () => _showFullImage(avatar),
                child: CircleAvatar(radius: 70, backgroundImage: avatar),
              ),
            ),
            const SizedBox(height: 20),
            // Nom complet affiché en gras et grande taille.
            Text(
              '${_currentLocalContact!.firstName} ${_currentLocalContact!.lastName}', 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 30),
            // Lignes d'informations structurées (E-mail et Téléphone).
            _buildDetailRow(Icons.email, 'Email', _currentLocalContact!.email),
            _buildDetailRow(Icons.phone, 'Téléphone', _currentLocalContact!.phone),
            const SizedBox(height: 40),
            // Bouton stylisé pour modifier les informations.
            ElevatedButton.icon(
              onPressed: () {}, // Action à implémenter.
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Modifier les informations', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🏗️ WIDGET RÉUTILISABLE : Construit proprement une ligne d'information détaillée (Icône + Titre + Valeur).
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 28),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }
}
