# 👥 ContactHive

**ContactHive** est une application mobile de gestion et de consultation de contacts développée avec le framework **Flutter** et le langage **Dart**. 
Ce projet universitaire met en œuvre une architecture logicielle propre (MVC), une interface utilisateur moderne et une gestion rigoureuse des flux 
asynchrones sans recours à une base de données externe.

## 🚀 1. Instructions de Lancement et Déploiement

Suivez ces étapes pour configurer l'environnement, installer les dépendances et exécuter l'application sur votre machine.

### 📋 Prérequis Systèmes
* **Flutter SDK :** Version 3.x (Canal stable) installée et configurée.
* **Dart SDK :** Version 3.x intégrée.
* **Environnement d'exécution :** Un émulateur Android, un simulateur iOS ou un appareil mobile physique avec le *Débogage USB* activé.
* **Outils recommandés :** VS Code (avec les extensions Flutter/Dart) ou Android Studio.

### 🛠️ Procédure d'Exécution

1. **Accéder à la racine du projet :**
   Ouvrez votre terminal et naviguez vers le répertoire du projet :
   ```bash
   cd contacthive
   Vérifier la configuration (Optionnel) :
Assurez-vous que votre environnement Flutter est prêt :

Bash
flutter doctor
Installer les dépendances :
Téléchargez les packages officiels requis par l'application (notamment image_picker pour la gestion des photos) :

Bash
flutter pub get
Lancer l'application :
Assurez-vous qu'un appareil (virtuel ou physique) est connecté et actif, puis lancez la compilation :

Bash
flutter run

🎯 2. Liste Exhaustive des Fonctionnalités
🔐 A. Authentification et Sécurité
Formulaire de Connexion : Interface dédiée aux identifiants utilisateurs (LoginScreen) avec blocage de la soumission si les champs sont vides.

Validation par Expressions Régulières (RegExp) : Contrôle de l'adresse email pour garantir le
respect du format standard (@ et nom de domaine valides).

📊 B. Tableau de Bord (Écran d'Accueil)
Calcul Dynamique de Statistiques : Lecture en temps réel du flux de données pour afficher le nombre total de contacts actifs.

Filtrage des Profils Enrichis : Analyse automatique de la base pour afficher le nombre de fiches disposant d'une photo personnalisée.

Section "Ajoutés Récents" : Composant graphique à défilement horizontal isolant automatiquement les 6 derniers contacts créés.

Navigation Contextuelle Rapide : Un clic sur l'avatar d'un contact récent ou sur les boutons d'actions
("Rechercher", "Ajouter") redirige instantanément vers l'écran fonctionnel.

🗂️ C. Gestion Opérationnelle CRUD (Écran Détails)
Recherche Prédictive en Temps Réel : Barre de filtrage dynamique triant instantanément la liste par nom,
prénom ou email à chaque lettre tapée (sans distinction de casse).

Création de Fiche (Create) : Formulaire complet pour renseigner le prénom, le nom, l'email
et le téléphone avec validation stricte (pas de chiffres dans les noms).

Lecture Isolée (Read) : Passage fluide d'une vue en liste globale à une fiche profil individuelle épurée au clic sur un contact.

Mise à Jour Dynamique (Update) : Édition complète des champs d'un contact existant avec répercussion
instantanée sur l'application et l'écran d'accueil.

Suppression Sécurisée (Delete) : Retrait immédiat d'un contact de la liste en mémoire vive 
avec rafraîchissement asynchrone automatique de l'interface.

📸 D. Fonctionnalités Système Intégrées
Sélection Multimédia Native : Menu contextuel inférieur (BottomSheet) offrant le choix entre la capture en direct (Appareil Photo) 
ou l'importation depuis l'historique (Galerie).

Gestion Double-Flux des Avatars : Algorithme chargeant l'image locale (FileImage) si elle existe,
ou basculant sur une image réseau par défaut (NetworkImage).

Visualisation Plein Écran (LightBox) : Un clic sur la miniature d'un avatar ouvre un dialogue
modal transparent mettant en valeur la photo en grand format.

🧭 E. Navigation et Robustesse
Interception du Retour Physique (PopScope) : Protection contre les retours matériels accidentels de l'appareil :

Depuis une fiche profil → Retour à la liste globale sans quitter l'écran.

Depuis la liste globale → Redirection vers l'Accueil sans déconnexion.

Dialogue de Déconnexion Sécurisé : Boîte de dialogue demandant une confirmation explicite
avant d'effacer la session et de ramener l'utilisateur à l'écran de Login.
lib/
│
├── models/
│   └── contact.dart          # MODÈLE : Définition de l'objet Contact et méthode copyWith (immutabilité)
│
├── screens/                  # VUES : Interfaces graphiques de l'application
│   ├── welcome_screen.dart   # Écran de bienvenue / Splash initial
│   ├── login_screen.dart     # Écran d'authentification (Formulaire & Validation)
│   ├── home_screen.dart      # Tableau de bord : Statistiques dynamiques et contacts récents
│   └── detail_screen.dart    # Liste globale, moteur de recherche, fiches profils et formulaires CRUD
│
├── services/                 # CONTRÔLEUR : Logique métier et gestion des données
│   └── api_service.dart      # Gestionnaire centralisé de la liste en mémoire vive (In-Memory)
│
└── main.dart                 # Point d'entrée de l'application, thème et configuration des routes

🎯 3. Liste Exhaustive des Fonctionnalités
🔐 A. Authentification et Sécurité
Formulaire de Connexion : Interface dédiée aux identifiants utilisateurs (LoginScreen) 
avec blocage de la soumission si les champs sont vides.

Validation par Expressions Régulières (RegExp) : Contrôle de l'adresse email pour garantir
le respect du format standard (@ et nom de domaine valides).

📊 B. Tableau de Bord (Écran d'Accueil)
Calcul Dynamique de Statistiques : Lecture en temps réel du flux de données pour afficher le nombre total de contacts actifs.

Filtrage des Profils Enrichis : Analyse automatique de la base pour afficher le nombre
de fiches disposant d'une photo personnalisée.

Section "Ajoutés Récents" : Composant graphique à défilement horizontal isolant automatiquement
les 6 derniers contacts créés.

Navigation Contextuelle Rapide : Un clic sur l'avatar d'un contact récent ou sur les boutons d'actions 
("Rechercher", "Ajouter") redirige instantanément vers l'écran fonctionnel.

🗂️ C. Gestion Opérationnelle CRUD (Écran Détails)
Recherche Prédictive en Temps Réel : Barre de filtrage dynamique triant instantanément 
la liste par nom, prénom ou email à chaque lettre tapée (sans distinction de casse).

Création de Fiche (Create) : Formulaire complet pour renseigner le prénom, le nom, 
l'email et le téléphone avec validation stricte (pas de chiffres dans les noms).

Lecture Isolée (Read) : Passage fluide d'une vue en liste globale à une fiche
profil individuelle épurée au clic sur un contact.

Mise à Jour Dynamique (Update) : Édition complète des champs d'un contact existant 
avec répercussion instantanée sur l'application et l'écran d'accueil.

Suppression Sécurisée (Delete) : Retrait immédiat d'un contact de la liste en mémoire
vive avec rafraîchissement asynchrone automatique de l'interface.

📸 D. Fonctionnalités Système Intégrées
Sélection Multimédia Native : Menu contextuel inférieur (BottomSheet) offrant le choixentre la capture en direct (Appareil Photo) ou l'importation depuis l'historique (Galerie).
Gestion Double-Flux des Avatars : Algorithme chargeant l'image locale (FileImage) si elle existe, ou basculant sur une image réseau par défaut (NetworkImage).
Visualisation Plein Écran (LightBox) : Un clic sur la miniature d'un avatar ouvre un dialogue modal transparent mettant en valeur la photo en grand format.

🧭 E. Navigation et Robustesse
Interception du Retour Physique (PopScope) : Protection contre les retours matériels accidentels de l'appareil :
Depuis une fiche profil $\rightarrow$ Retour à la liste globale sans quitter l'écran.
Depuis la liste globale $\rightarrow$ Redirection vers l'Accueil sans déconnexion.
Dialogue de Déconnexion Sécurisé : Boîte de dialogue demandant une confirmation explicite avant d'effacer la session et de ramener l'utilisateur à l'écran de Login.

🏁 4. Conclusion Technique
Le développement de l'application ContactHive a permis de consolider les concepts fondamentaux du développement mobile sous Flutter.
L'implémentation réussie du cycle de vie des widgets asynchrones via le composant FutureBuilder offre une expérience utilisateur
réactive et sans latence visuelle, indispensable aux standards du marché.
En intégrant des mécanismes avancés comme le pattern MVC, la gestion fine des images locales via le stockage natif et la
sécurisation des flux de navigation grâce au composant PopScope, ce projet démontre qu'il est tout à fait possible de concevoir
une application robuste, fluide et conforme aux contraintes d'ingénierie logicielle actuelles, tout en respectant 
un environnement d'exécution simulé en mémoire vive.
