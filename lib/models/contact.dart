// Définition du modèle de données pour un Contact
class Contact {
  final String id;              // Identifiant unique du contact
  final String firstName;       // Prénom du contact
  final String lastName;        // Nom de famille
  final String email;           // Adresse email
  final String phone;           // Numéro de téléphone
  final String imageUrl;        // URL de l'image (provenant de l'API)
  final String? localImagePath; // Chemin local si l'utilisateur change la photo

  // Constructeur de la classe
  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.imageUrl,
    this.localImagePath,
  });

  // Constructeur "factory" pour créer un objet Contact à partir d'un format JSON (API)
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      // On récupère l'identifiant unique ou on en génère un par défaut
      id: json['login']?['uuid'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      // Extraction sécurisée des données avec des valeurs par défaut si null
      firstName: json['name']?['first'] ?? 'Sans prénom',
      lastName: json['name']?['last'] ?? 'Sans nom',
      email: json['email'] ?? 'Pas d\'email',
      phone: json['phone'] ?? 'Pas de numéro',
      // Image de profil fournie par l'API
      imageUrl: json['picture']?['large'] ?? 'https://via.placeholder.com/150',
    );
  }

  // Méthode copyWith pour créer une nouvelle instance en modifiant seulement certains champs
  // Très utile pour mettre à jour un contact sans muter l'objet original
  Contact copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? imageUrl,
    String? localImagePath,
  }) {
    return Contact(
      id: this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }
}
