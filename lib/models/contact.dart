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

  // Constructeur "factory" adaptatif pour créer un objet Contact à partir d'un format JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      // On récupère l'id direct ou dans le sous-objet login (Random User)
      id: json['id'] ?? json['login']?['uuid'] ?? DateTime.now().millisecondsSinceEpoch.toString(),

      // Sécurité adaptative : on cherche d'abord la clé plate, sinon dans le sous-objet 'name'
      firstName: json['firstName'] ?? json['name']?['first'] ?? 'Sans prénom',
      lastName: json['lastName'] ?? json['name']?['last'] ?? 'Sans nom',

      email: json['email'] ?? 'Pas d\'email',
      phone: json['phone'] ?? 'Pas de numéro',

      // On cherche l'imageUrl directe ou dans le sous-objet 'picture'
      imageUrl: json['imageUrl'] ?? json['picture']?['large'] ?? 'https://via.placeholder.com/150',

      localImagePath: json['localImagePath'],
    );
  }

  // Méthode copyWith pour créer une nouvelle instance en modifiant seulement certains champs
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