import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentPage = 0;
  String? _songInfo;
  late AnimationController _animationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.7).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildMainPage(),
          _buildLibraryPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMainPage() {
    return Center(
      child: GestureDetector(
        onTapDown: (details) {
          _animationController.forward();
          searchSong();
        },
        onTapUp: (details) {
          _animationController.reverse();
        },
        onTapCancel: () {
          _animationController.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.music_note, size: 50, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryPage() {
    return Center(
      child: Text(
        _songInfo ?? "Biblioteca",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.search),
          color: _currentPage == 0 ? Colors.blue : Colors.grey,
          onPressed: () {
            _pageController.jumpToPage(0);
          },
        ),
        SizedBox(width: 20),
        IconButton(
          icon: Icon(Icons.library_music),
          color: _currentPage == 1 ? Colors.blue : Colors.grey,
          onPressed: () {
            _pageController.jumpToPage(1);
          },
        ),
      ],
    );
  }

  
    Future<bool> requestMicrophonePermission() async {
    PermissionStatus permission = await Permission.microphone.request();
    return permission.isGranted;
  }

  Future<void> searchSong() async {
    bool hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      print('Permiso del micrófono no otorgado');
      return;
    }

    FlutterSoundRecorder _recorder = FlutterSoundRecorder();
    String? path;

    try {
      // 1. Grabar audio
      _recorder = FlutterSoundRecorder();
      await _recorder.openRecorder();
      final tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}/temp.aac';
      await Future.delayed(Duration(seconds: 10)); // graba por 10 segundos
      await _recorder.stopRecorder();
      await _recorder.closeRecorder();
    } catch (e) {
      print("Error durante la grabación: $e");
      return;
    }

    if (path == null) {
      print("Error: Path de grabación es null");
      return;
    }

    try {
      // 2. Convertir el audio grabado a base64
      File audioFile = File(path);
      List<int> audioBytes = audioFile.readAsBytesSync();
      String base64Audio = base64Encode(audioBytes);

      // 3. Enviar a Shazam
      var url = Uri.parse('https://shazam.p.rapidapi.com/songs/detect');
      var response = await http.post(
        url,
        headers: {
          'content-type': 'text/plain',
          'X-RapidAPI-Key':
              '25d385af53mshf10a8ccb2262289p159852jsn614ebb5db896', // Asegúrate de usar tu propia clave API
          'X-RapidAPI-Host': 'shazam.p.rapidapi.com',
        },
        body: base64Audio,
      );

      // 4. Procesar la respuesta
      if (response.statusCode == 200) {
        // Decodificando la respuesta JSON
        var responseData = jsonDecode(response.body);

        // Extrayendo información de la respuesta
        String title = responseData['track']['title'];
        String artist = responseData['artists'][0]['name'];

        // Actualizando la UI
        setState(() {
          _songInfo = '$title by $artist';
        });

        // Guardando la información en Firebase
        saveSong(title, artist);
      } else {
        print('Failed to load song info. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error al procesar o enviar la solicitud: $e");
    }
  }

  Future<void> saveSong(String title, String artist) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('songs')
          .add({
        'title': title,
        'artist': artist,
        'timestamp': DateTime.now(),
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
