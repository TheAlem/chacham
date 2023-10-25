import 'package:chacham/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginScreen.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegurarse de que los bindings estén inicializados
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Crear una instancia del futuro para Firebase.initializeApp
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Especificar el futuro que el FutureBuilder debería escuchar
      future: _initialization,
      builder: (context, snapshot) {
        // Comprobar errores
        if (snapshot.hasError) {
          return SomethingWentWrong(); // Tu widget de error personalizado
        }

        // Una vez que el Future está completo y no hay errores, mostrar el widget de tu aplicación
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Mi App',
            home: LoginScreen(),
          );
        }

        // Mientras esperamos que se complete el Future, muestra un indicador de carga
        return Loading(); // Tu widget de carga personalizado
      },
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Algo salió mal"),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
