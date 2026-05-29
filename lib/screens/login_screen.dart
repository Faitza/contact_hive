import 'package:flutter/material.dart';
import '../services/api_service.dart';

// Écran de connexion permettant à l'utilisateur de s'authentifier
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs pour récupérer le texte saisi dans les champs Email et Mot de passe
  // On met des valeurs par défaut pour faciliter les tests (API ReqRes)
  final _emailController = TextEditingController(text: 'eve.holt@reqres.in');
  final _passwordController = TextEditingController(text: 'cityslicka');
  
  // Variables d'état pour gérer l'affichage du mot de passe et l'état de chargement
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Fonction déclenchée lors de l'appui sur le bouton "Login"
  void _handleLogin() async {
    setState(() {
      _isLoading = true; // Active l'indicateur de chargement
    });

    // Appel au service API pour vérifier les identifiants
    bool success = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false; // Désactive l'indicateur de chargement
    });

    if (success) {
      // Si succès, on redirige vers l'écran d'accueil en remplaçant la page actuelle
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // En cas d'échec, on affiche un message d'erreur (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur de connexion. Vérifiez vos identifiants.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Libération de la mémoire utilisée par les contrôleurs quand le widget est détruit
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌆 1. Image d'arrière-plan (identique au Welcome Screen pour la cohérence)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.pinimg.com/736x/a9/49/1d/a9491d457163f5d85a03fa23c51b95a2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 🖤 2. Filtre sombre pour garantir la lisibilité
          Container(
            color: Colors.black.withOpacity(0.55),
          ),
          // 📝 3. Formulaire de connexion
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Champ de saisie Email
                    const Text(
                      'Email',
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Enter your Email',
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Champ de saisie Mot de passe
                    const Text(
                      'Password',
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible, // Masque le texte si nécessaire
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.shield_outlined, color: Colors.black54),
                        // Bouton pour afficher/masquer le mot de passe
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 44),
                    
                    // Bouton de connexion
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin, // Désactivé si en cours de chargement
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
