import 'package:flutter/material.dart';

// Définition de la classe WelcomeScreen qui représente l'écran d'accueil.
// C'est un StatelessWidget car son interface ne change pas d'état interne après sa création.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Le Scaffold est le widget de base qui fournit la structure visuelle de la page.
    return Scaffold(
      // On utilise un Stack pour superposer les éléments : Fond -> Filtre -> Contenu.
      body: Stack(
        children: [
          // 🌆 1. Image d'arrière-plan.
          // Un Container décoré d'une image pour occuper tout l'écran.
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Récupération de l'image depuis une URL réseau.
                image: NetworkImage('https://i.pinimg.com/736x/a9/49/1d/a9491d457163f5d85a03fa23c51b95a2.jpg'),
                // BoxFit.cover permet à l'image de remplir tout l'espace sans être déformée.
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🖤 2. Filtre sombre semi-transparent (Overlay).
          // Ce Container applique un voile noir par-dessus l'image pour faire ressortir le texte blanc.
          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          // 🚀 3. Contenu principal de l'écran.
          // SafeArea garantit que le contenu n'est pas coupé par les encoches ou barres système.
          SafeArea(
            child: Padding(
              // Padding symétrique pour décoller le contenu des bords de l'écran.
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                // Aligne les éléments verticalement au centre.
                mainAxisAlignment: MainAxisAlignment.center,
                // Étire les éléments (comme le bouton) sur toute la largeur.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Spacer occupe l'espace vide pour équilibrer la mise en page.
                  const Spacer(),

                  // ⬢ Icône centrale représentant l'identité visuelle de l'app.
                  const Center(
                    child: Icon(
                      Icons.polyline_outlined, // Icône moderne évoquant un réseau ou une ruche.
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                  // SizedBox ajoute un espace vertical fixe entre l'icône et le texte.
                  const SizedBox(height: 16),

                  // 🏷️ Titre de l'application.
                  const Text(
                    'ContactHive',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✍️ Phrase d'accroche (Slogan).
                  const Text(
                    'Votre réseau, parfaitement synchronisé.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  // Second Spacer pour pousser le bouton d'action vers le bas.
                  const Spacer(),

                  // 🔴 Bouton d'action principal pour commencer.
                  ElevatedButton(
                    onPressed: () {
                      // Déclenche la navigation vers l'écran de connexion.
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914), // Couleur rouge vif.
                      foregroundColor: Colors.white, // Couleur du texte/icône dans le bouton.
                      padding: const EdgeInsets.symmetric(vertical: 18), // Hauteur du bouton.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Bords légèrement arrondis.
                      ),
                      elevation: 0, // Style plat sans ombre.
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Commencer',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        SizedBox(width: 10), // Espace entre le texte et l'icône de flèche.
                        Icon(Icons.arrow_forward_ios, size: 16), // Petite flèche indicative.
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Marge de sécurité en bas de l'écran.
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
