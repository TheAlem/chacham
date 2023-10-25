// Paquetes de Flutter
import 'package:flutter/material.dart';

// Paquetes para autenticación
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chacham/MyhomePage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  // Instancias de autenticación
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

    // Método para iniciar sesión con Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        // Si la autenticación es exitosa, navega a la página principal
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyHomePage(title: 'Flutter Demo Home Page'),
            ),
          );
        }
      }
    } catch (error) {
      print(error); // Imprimir errores para depuración
    }
  }
  
  // Método build para renderizar la UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Fondo oscuro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Iniciar sesión',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // Color de fondo del botón
                onPrimary: Colors.black, // Color del texto y del ícono
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bordes redondeados
                ),
              ),
              icon: Image.asset('image/Sangoogle.png',
                  height:
                      24), // Asegúrate de agregar el logo de Google a tus assets y cambiar la ruta 'path_to_google_logo.png' a la correcta
              label: Text('Continuar con Google'),
              onPressed: _signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}

