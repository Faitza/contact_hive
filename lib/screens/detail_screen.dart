import 'dart:io'; // Permet de manipuler les fichiers du système (ex: photos locales)
import 'package:flutter/material.dart'; // Framework UI de Flutter
import 'package:image_picker/image_picker.dart'; // Package pour sélectionner des images (galerie/caméra)
import '../models/contact.dart'; // Modèle de données pour les contacts
import '../services/api_service.dart'; // Service pour les appels API et le cache
import 'home_screen.dart'; // Écran d'accueil pour la navigation

/// 📱 CLASSE DETAILSCREEN
/// Cet écran gère deux affichages :
/// 1. La liste de tous les contacts avec barre de recherche (Mode Liste).
/// 2. Les informations détaillées d'un contact sélectionné (Mode Fiche).
class DetailScreen extends StatefulWidget {
  final Contact? contact; // Contact optionnel passé lors de la navigation
  const DetailScreen({super.key, this.contact});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // ---------------------------------------------------------
  // 📦 VARIABLES D'ÉTAT (DONNÉES)
  // ---------------------------------------------------------
  
  late Future<List<Contact>> _contactsFuture; // Future pour charger la liste de manière asynchrone
  final TextEditingController _searchController = TextEditingController(); // Contrôle le champ de recherche
  String _searchQuery = ""; // Stocke le texte de recherche en minuscule pour le filtrage
  String? _tempFormImagePath; // Chemin temporaire d'une image choisie en galerie
  Contact? _currentLocalContact; // Le contact actuellement affiché en "Mode Fiche"

  // 🔒 CLÉS DE FORMULAIRE (SÉCURITÉ)
  // Permettent de valider les champs (nom, email...) avant d'autoriser l'enregistrement.
  final _addFormKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();

  // 📝 CONTRÔLEURS DE TEXTE
  // Utilisés pour récupérer ce que l'utilisateur écrit dans les formulaires.
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Au démarrage, on vérifie si on a reçu un contact à afficher.
    if (widget.contact != null) {
      _currentLocalContact = widget.contact;
    }
    _refreshGlobalList(); // Initialise le chargement des contacts
    
    // Écoute les changements dans la barre de recherche pour filtrer en temps réel.
    _searchController.addListener(() {
      setState(() { _searchQuery = _searchController.text.toLowerCase(); });
    });
  }

  /// 🌐 RÉCUPÉRATION RÉSEAU
  /// Demande au service API de fournir la liste des contacts.
  void _refreshGlobalList() {
    setState(() {
      _contactsFuture = ApiService.getContacts();
    });
  }

  /// 🚪 MÉTHODE : DÉCONNEXION
  /// Affiche une boîte de dialogue de confirmation avant de renvoyer vers l'écran de Login.
  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // --- ✅ FONCTIONS DE VALIDATION (CONTRÔLE DE SAISIE) ---

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est obligatoire';
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-'\s]+$").hasMatch(value.trim())) return 'Lettres uniquement';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est obligatoire';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Format d\'email invalide';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le numéro est obligatoire';
    if (!RegExp(r'^\+?[0-9\s\-]{8,15}$').hasMatch(value.trim())) return 'Numéro invalide';
    return null;
  }

  // --- 📸 GESTION DES IMAGES ---

  /// Ouvre le sélecteur d'image (Galerie ou Caméra).
  Future<void> _pickImageForForm(StateSetter setDialogState, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      // Met à jour l'image UNIQUEMENT à l'intérieur de la boîte de dialogue.
      setDialogState(() { _tempFormImagePath = image.path; });
    }
  }

  /// Affiche le menu de choix de source (Galerie/Appareil).
  void _showImageSourceMenu(StateSetter setDialogState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library, color: Colors.blue), title: const Text('Galerie'), onTap: () { Navigator.pop(context); _pickImageForForm(setDialogState, ImageSource.gallery); }),
            ListTile(leading: const Icon(Icons.camera_alt, color: Colors.green), title: const Text('Appareil photo'), onTap: () { Navigator.pop(context); _pickImageForForm(setDialogState, ImageSource.camera); }),
          ],
        ),
      ),
    );
  }

  /// Affiche la photo de profil en plein écran au clic.
  void _showFullImage(ImageProvider imageProvider) {
    showDialog(context: context, builder: (context) => Dialog(backgroundColor: Colors.transparent, child: GestureDetector(onTap: () => Navigator.pop(context), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image(image: imageProvider, fit: BoxFit.contain)))));
  }

  // --- 🏗️ FORMULAIRES ---

  /// Dialogue pour la création d'un nouveau contact.
  void _showAddContactDialog() {
    _firstNameController.clear(); _lastNameController.clear(); _emailController.clear(); _phoneController.clear(); _tempFormImagePath = null;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau Contact', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: _addFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceMenu(setDialogState),
                    child: CircleAvatar(radius: 40, backgroundColor: Colors.grey.shade300, backgroundImage: _tempFormImagePath != null ? FileImage(File(_tempFormImagePath!)) : null, child: _tempFormImagePath == null ? const Icon(Icons.add_a_photo, color: Colors.white) : null),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'Prénom'), validator: _validateName),
                  TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Nom'), validator: _validateName),
                  TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: _validateEmail),
                  TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone'), validator: _validatePhone),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                if (_addFormKey.currentState!.validate()) {
                  final newContact = Contact(id: DateTime.now().millisecondsSinceEpoch.toString(), firstName: _firstNameController.text.trim(), lastName: _lastNameController.text.trim(), email: _emailController.text.trim(), phone: _phoneController.text.trim(), imageUrl: 'https://via.placeholder.com/150', localImagePath: _tempFormImagePath);
                  ApiService.addContact(newContact);
                  Navigator.pop(context);
                  _refreshGlobalList();
                }
              },
              child: const Text('Ajouter', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialogue pour la modification d'un contact existant.
  void _showEditContactDialog(Contact contact) {
    _firstNameController.text = contact.firstName; _lastNameController.text = contact.lastName; _emailController.text = contact.email; _phoneController.text = contact.phone; _tempFormImagePath = contact.localImagePath;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier le Contact'),
          content: SingleChildScrollView(
            child: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceMenu(setDialogState),
                    child: CircleAvatar(radius: 40, backgroundColor: Colors.grey.shade300, backgroundImage: _tempFormImagePath != null ? FileImage(File(_tempFormImagePath!)) : _getAvatar(contact), child: const Icon(Icons.edit, color: Colors.white70)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'Prénom'), validator: _validateName),
                  TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Nom'), validator: _validateName),
                  TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: _validateEmail),
                  TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone'), validator: _validatePhone),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                if (_editFormKey.currentState!.validate()) {
                  final updated = contact.copyWith(firstName: _firstNameController.text.trim(), lastName: _lastNameController.text.trim(), email: _emailController.text.trim(), phone: _phoneController.text.trim(), localImagePath: _tempFormImagePath);
                  ApiService.updateContact(updated);
                  Navigator.pop(context);
                  _refreshGlobalList();
                  if (_currentLocalContact != null) {
                    setState(() { _currentLocalContact = updated; });
                  }
                }
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// Détermine si l'image doit être chargée depuis le stockage local ou le web.
  ImageProvider _getAvatar(Contact contact) {
    if (contact.localImagePath != null && contact.localImagePath!.isNotEmpty) {
      return FileImage(File(contact.localImagePath!));
    }
    return NetworkImage(contact.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 POPSCOPE : Gère intelligemment le bouton "Retour" physique du téléphone.
    return PopScope(
      canPop: false, // On bloque le retour automatique pour appliquer notre logique
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_currentLocalContact != null) {
          // Si on est sur une fiche profil -> Retour à la liste
          setState(() { _currentLocalContact = null; });
        } else {
          // Si on est sur la liste -> Retour à l'écran d'accueil
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      },
      child: _buildMainContent(),
    );
  }

  /// Construit le contenu visuel principal selon l'état actuel (Liste ou Fiche).
  Widget _buildMainContent() {
    // --- CAS A : AFFICHAGE DE LA LISTE GLOBALE ---
    if (_currentLocalContact == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        appBar: AppBar(
          title: const Text('ContactHive', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: Colors.black87), onPressed: _refreshGlobalList),
            IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _logout),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Barre de recherche
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
              // Liste asynchrone gérée par FutureBuilder
              Expanded(
                child: FutureBuilder<List<Contact>>(
                  future: _contactsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError) return Center(child: Text('Erreur : ${snapshot.error}'));
                    
                    final contacts = snapshot.data ?? [];
                    // Filtrage dynamique selon la saisie
                    final filtered = contacts.where((c) {
                      final fullName = '${c.firstName} ${c.lastName}'.toLowerCase();
                      return fullName.contains(_searchQuery) || c.email.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) return const Center(child: Text('Aucun résultat trouvé.'));

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        final avatar = _getAvatar(c);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: GestureDetector(onTap: () => _showFullImage(avatar), child: CircleAvatar(backgroundImage: avatar)),
                            title: Text('${c.firstName} ${c.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(c.email),
                            onTap: () => setState(() { _currentLocalContact = c; }),
                            trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showEditContactDialog(c)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(backgroundColor: Colors.orange, onPressed: _showAddContactDialog, child: const Icon(Icons.person_add, color: Colors.white)),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: Colors.orange,
          onTap: (index) { if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())); },
          items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'), BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Détails')],
        ),
      );
    }

    // --- CAS B : AFFICHAGE DE LA FICHE DÉTAILLÉE ---
    final avatar = _getAvatar(_currentLocalContact!);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => setState(() { _currentLocalContact = null; })),
        title: const Text('Fiche Contact', style: TextStyle(color: Colors.black87)),
        actions: [IconButton(icon: const Icon(Icons.edit, color: Colors.black87), onPressed: () => _showEditContactDialog(_currentLocalContact!))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(child: GestureDetector(onTap: () => _showFullImage(avatar), child: CircleAvatar(radius: 70, backgroundImage: avatar))),
            const SizedBox(height: 20),
            Text('${_currentLocalContact!.firstName} ${_currentLocalContact!.lastName}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildDetailRow(Icons.email, 'Email', _currentLocalContact!.email),
            _buildDetailRow(Icons.phone, 'Téléphone', _currentLocalContact!.phone),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _showEditContactDialog(_currentLocalContact!),
              icon: const Icon(Icons.camera_alt, color: Colors.orange),
              label: const Text('Modifier les informations', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une ligne d'information détaillée (Icône + Titre + Valeur).
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
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }
}
